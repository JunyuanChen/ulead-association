module ApplicationHelper
  CSS_ALERTS = %i[primary secondary success danger warning info light dark].freeze

  def css_alert?(alert_type)
    CSS_ALERTS.include? alert_type.to_sym
  end

  def nav_link(name, path, method: :get, usr_class: '')
    content_tag :li,
                if method == :get
                  link_to name, path, class: "nav-link #{usr_class}".strip
                else
                  link_to name, path,
                          method: method,
                          class: "nav-link #{usr_class}".strip
                end,
                class: 'navbar-item'
  end
end
