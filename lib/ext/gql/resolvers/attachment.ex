defmodule Ext.Gql.Resolvers.Attachment do
  @moduledoc false

  def url(uploader, version \\ nil) do
    fn parent, _args, %{definition: %{schema_node: %{identifier: field_name}}} ->
      {:ok, uploader.url({Ext.Utils.Base.get_in(parent, [field_name]), parent}, version, signed: true)}
    end
  end
end
