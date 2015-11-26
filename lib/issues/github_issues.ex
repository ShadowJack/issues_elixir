defmodule Issues.GithubIssues do
  require Logger

  @user_agent [{"User-agent", "Elixir kostyap@hotmail.ru"}]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    Logger.info "Fetching user #{user}, project #{project}"
    HTTPoison.start
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project), do: "#{@github_url}/repos/#{user}/#{project}/issues"

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    Logger.info "Successfull response"
    Logger.debug fn -> inspect(body) end
    {:ok, :jsx.decode(body)}
  end
  def handle_response({:ok, %HTTPoison.Response{status_code: _, body: body}}) do
    Logger.info "Something went wrong"
    Logger.debug fn -> inspect(body) end
    {:error, :jsx.decode(body)}
  end
  def handle_response({:error, %HTTPoison.Error{reason: reason}}) do
    Logger.info "Error has occured"
    Logger.debug fn -> inspect(reason) end
    {:error, reason}
  end
end
