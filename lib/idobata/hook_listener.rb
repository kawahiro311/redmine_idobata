# -*- coding: utf-8 -*-
class IdobataHookListener < Redmine::Hook::Listener

  def controller_issues_new_after_save(context = {})
    issue = context[:issue]
    project = issue.project

    return unless hook_url_configured?(project)

    author  = escape(issue.author.login)
    subject = escape(issue.subject)
    url     = get_url(issue)
    text    = "[#{escape project.name}] #{author} created <a href=\"#{url}\">##{issue.id} #{subject}</a>"

    notify(text, project)
  end

  def controller_issues_edit_after_save(context = {})
    issue = context[:issue]
    project = issue.project

    return unless hook_url_configured?(project)

    author  = escape(issue.author.login)
    subject = escape(issue.subject)
    url     = get_url(issue)
    comment = escape(context[:journal].notes)
    text    = "[#{escape project.name}] #{author} updated <a href=\"#{url}\">##{issue.id} #{subject}</a>"
    text   += ": #{truncate comment}" unless comment.blank?

    notify(text, project)
  end

  def controller_wiki_edit_after_save(context = {})
    page = context[:page]
    project = page.wiki.project

    return unless hook_url_configured?(project)

    author  = escape(page.content.author.login)
    url     = get_url(page)
    text    = "[#{escape project.name}] #{author} edited wiki page <a href=\"#{url}\">#{escape page.pretty_title}</a>"

    notify(text, project)
  end

  private

  def hook_url_configured?(project)
    project.idobata_webhook_url.present?
  end

  def escape(text)
    CGI::escapeHTML(text)
  end

  def get_url(obj)
    Rails.application.routes.url_for(obj.event_url :host => Setting.host_name)
  end

  def truncate(text)
    text.size > 30 ? "#{text.slice(0, 30)}..." : text
  end

  def headers
    {
      'User-Agent'  => "redmine_idobata / 0.0.1"
    }
  end

  def notify(text, project)
    uri = URI.parse(project.idobata_webhook_url)
    req = Net::HTTP::Post.new(uri.request_uri, headers)
    req.form_data = { 'source' => text, 'format' => 'html' }

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    https.start { |h| h.request(req) }
  end
end
