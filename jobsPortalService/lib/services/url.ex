defmodule Services.Url do
  def user_endp(endpoint_url) do
    Application.get_env(:portal_management, :user_management_service_url) <> endpoint_url
  end

  def posting_endp(endpoint_url) do
    Application.get_env(:portal_management, :posting_management_service_url) <> endpoint_url
  end

  def stat_endp(endpoint_url) do
    Application.get_env(:portal_management, :statistics_service_url) <> endpoint_url
  end

end