defmodule TagzUpWeb.API.AuthController do
  use TagzUpWeb, :controller
  alias TagzUp.Accounts.User

  def register(conn, %{"email" => email, "password" => password, "user_type" => user_type} = params) do
    case User.register_with_password(%{
      email: email,
      password: password,
      password_confirmation: password,
      user_type: String.to_atom(user_type),
      phone: params["phone"]
    }) do
      {:ok, user} ->
        token = AshAuthentication.user_to_token(user, %{})
        
        conn
        |> put_status(:created)
        |> json(%{
          success: true,
          data: %{
            user: %{
              id: user.id,
              email: user.email,
              user_type: user.user_type,
              status: user.status
            },
            token: token
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          errors: format_errors(changeset)
        })
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case User.sign_in_with_password(%{email: email, password: password}) do
      {:ok, user, token} ->
        conn
        |> json(%{
          success: true,
          data: %{
            user: %{
              id: user.id,
              email: user.email,
              user_type: user.user_type,
              status: user.status
            },
            token: token
          }
        })

      {:error, _error} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          success: false,
          error: "Invalid email or password"
        })
    end
  end

  def me(conn, _params) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{success: false, error: "Not authenticated"})

      user ->
        conn
        |> json(%{
          success: true,
          data: %{
            user: %{
              id: user.id,
              email: user.email,
              user_type: user.user_type,
              status: user.status
            }
          }
        })
    end
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end