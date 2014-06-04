class IdobataViewHook < Redmine::Hook::ViewListener
  render_on(:view_projects_form, :partial => 'projects/redmine_idobata', :layout => false)
end
