# -*- coding: utf-8 -*-
class IdobataHookListener < Redmine::Hook::Listener

  def controller_issues_new_after_save(context = {})
    issue = context[:issue]
    project = issue.project

    return if hook_url(project).blank?

    author  = escape(issue.author.login)
    subject = escape(issue.subject)
    url     = get_url(issue)
    text    = "[#{escape project.name}] #{author} created <a href=\"#{url}\">##{issue.id} #{subject}</a>"

    notify(text, project)
  end

  def controller_issues_edit_after_save(context = {})
    issue = context[:issue]
    journal = context[:journal]
    project = issue.project

    return if hook_url(project).blank?

    author  = escape(journal.user.login)
    subject = escape(issue.subject)
    url     = get_url(issue)
    comment = escape(journal.notes)
    text    = "[#{escape project.name}] #{author} updated <a href=\"#{url}\">##{issue.id} #{subject}</a>"
    text   += "<br/><blockquote>#{truncate comment.gsub(/(\r\n|\r|\n)/, '<br/>')}</blockquote>" unless comment.blank?

    notify(text, project)
  end

  def controller_wiki_edit_after_save(context = {})
    page = context[:page]
    project = page.wiki.project

    return if hook_url(project).blank?

    author  = escape(page.content.author.login)
    url     = get_url(page)
    text    = "[#{escape project.name}] #{author} edited wiki page <a href=\"#{url}\">#{escape page.pretty_title}</a>"

    notify(text, project)
  end

  def controller_messages_new_after_save(context = {})
    message = context[:message]
    project = message.project

    return if hook_url(project).blank?

    author  = escape(message.author.login)
    subject = escape(message.subject)
    url     = get_url(message)
    comment = escape(message.content)
    text    = "[#{escape project.name}] #{author} posted new message <a href=\"#{url}\">#{escape subject}</a>"
    text   += "<br/><blockquote>#{truncate comment.gsub(/(\r\n|\r|\n)/, '<br/>')}</blockquote>" unless comment.blank?

    notify(text, project)
  end

  def controller_messages_reply_after_save(context = {})
    message = context[:message]
    project = message.project

    return if hook_url(project).blank?

    author  = escape(message.author.login)
    subject = escape(message.subject)
    url     = get_url(message)
    comment = escape(message.content)
    text    = "[#{escape project.name}] #{author} posted reply message <a href=\"#{url}\">#{escape subject}</a>"
    text   += "<br/><blockquote>#{truncate comment.gsub(/(\r\n|\r|\n)/, '<br/>')}</blockquote>" unless comment.blank?

    notify(text, project)
  end

  private

  def hook_url(project)
    pcf = ProjectCustomField.find_by_name('Idobata Webhook URL')
    project.custom_value_for(pcf).try(:value).presence || Setting.plugin_redmine_idobata[:idobata_webhook_url]
  end

  def escape(text)
    CGI::escapeHTML(text)
  end

  def get_url(obj)
    Rails.application.routes.url_for(obj.event_url :host => Setting.host_name)
  end

  def truncate(text)
    text.size > 500 ? "#{text.slice(0, 500)}..." : text
  end

  def headers
    {
      'User-Agent'  => "redmine_idobata / 0.0.1"
    }
  end

  def notify(text, project)
    uri = URI.parse(hook_url(project))
    req = Net::HTTP::Post.new(uri.request_uri, headers)
    req.form_data = { 'source' => text, 'format' => 'html' }

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.start { |h| h.request(req) }
  end
end
