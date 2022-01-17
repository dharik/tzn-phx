defmodule Tzn.Files do
  alias Tzn.Files.MenteeFile
  alias Tzn.Repo

  @bucket Application.get_env(:tzn, :s3_bucket)

  def get_signed_url(%MenteeFile{} = file, expires_in \\ 3600) do
    {:ok, url} =
      ExAws.S3.presigned_url(ExAws.Config.new(:s3), :get, @bucket, file.object_path,
        expires_in: expires_in
      )

    url
  end

  def get_mentee_file!(id) do
    Repo.get!(MenteeFile, id) |> Repo.preload([:user, :mentee, :questionnaire])
  end

  def delete(%MenteeFile{} = file) do
    MenteeFile.delete_changeset(file, %{deleted_at: Timex.now()}) |> Repo.update()
  end

  def upload!(object_path, content, meta, type) do
    ExAws.S3.put_object(@bucket, object_path, content, [meta: meta, content_type: type])
    |> ExAws.request!()
  end

  def upload(object_path, content, meta, type) do
    ExAws.S3.put_object(@bucket, object_path, content, [meta: meta, content_type: type])
    |> ExAws.request()
  end
end
