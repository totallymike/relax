defmodule Relax.PlugParser do
  @behaviour Plug.Parsers
  alias Plug.Conn

  def parse(conn, "application", "vnd.api+json", _headers, opts) do
    conn
      |> Conn.read_body(opts)
      |> decode
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp decode({:more, _, conn}) do
    {:error, :too_large, conn}
  end

  defp decode({:ok, "", conn}) do
    {:ok, %{}, conn}
  end

  defp decode({:ok, body, conn}) do
    decoded = body
      |> Poison.decode!
      |> Relax.Formatter.JsonApiOrg.parse
    {:ok, decoded, conn}
  end
end
