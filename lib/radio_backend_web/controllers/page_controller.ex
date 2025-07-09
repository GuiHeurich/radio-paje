defmodule RadioBackendWeb.PageController do
  use RadioBackendWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: false)
  end
end
