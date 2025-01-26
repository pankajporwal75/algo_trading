module ApplicationHelper
  def get_flash_type(type)
    return 'success' if type == 'notice'
    return 'error' if type == 'alert'
    return 'info' if type == 'info'
    return 'warning' if type == 'warning'
  end
end
