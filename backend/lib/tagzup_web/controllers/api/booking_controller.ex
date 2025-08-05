defmodule TagzUpWeb.API.BookingController do
  use TagzUpWeb, :controller
  alias TagzUp.Bookings.{Booking, Payment}
  alias TagzUp.Business.BusinessProfile
  alias TagzUp.Creators.{InfluencerProfile, Package}

  def create(conn, %{"package_id" => package_id} = params) do
    current_user = conn.assigns[:current_user]
    
    with {:ok, business_profile} <- get_business_profile(current_user.id),
         {:ok, package} <- Package.read(package_id),
         {:ok, influencer_profile} <- InfluencerProfile.read(package.influencer_profile_id) do
      
      platform_fee_rate = 0.15 # 15% platform fee
      platform_fee = Decimal.mult(package.price, Decimal.new(platform_fee_rate))
      influencer_amount = Decimal.sub(package.price, platform_fee)

      booking_params = %{
        business_profile_id: business_profile.id,
        influencer_profile_id: influencer_profile.id,
        package_id: package.id,
        total_amount: package.price,
        platform_fee: platform_fee,
        influencer_amount: influencer_amount,
        currency: package.currency,
        brief: params["brief"],
        requirements: params["requirements"],
        deadline: params["deadline"] && DateTime.from_iso8601(params["deadline"])
      }

      case Booking.create(booking_params) do
        {:ok, booking} ->
          conn
          |> put_status(:created)
          |> json(%{
            success: true,
            data: format_booking(booking)
          })

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{
            success: false,
            errors: format_errors(changeset)
          })
      end
    else
      {:error, :business_profile_not_found} ->
        conn
        |> put_status(:forbidden)
        |> json(%{success: false, error: "Business profile required"})

      {:error, _error} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Package not found"})
    end
  end

  def index(conn, _params) do
    current_user = conn.assigns[:current_user]
    
    bookings = case current_user.user_type do
      :business ->
        with {:ok, business_profile} <- get_business_profile(current_user.id) do
          Booking.by_business!(business_profile.id)
        else
          _ -> []
        end
      
      :influencer ->
        with {:ok, influencer_profile} <- get_influencer_profile(current_user.id) do
          Booking.by_influencer!(influencer_profile.id)
        else
          _ -> []
        end
      
      :admin ->
        Booking.read!()
    end

    conn
    |> json(%{
      success: true,
      data: Enum.map(bookings, &format_booking/1)
    })
  end

  def show(conn, %{"id" => id}) do
    case Booking.read(id) do
      {:ok, booking} ->
        # Check if user has access to this booking
        current_user = conn.assigns[:current_user]
        
        has_access = case current_user.user_type do
          :admin -> true
          :business ->
            with {:ok, business_profile} <- get_business_profile(current_user.id) do
              booking.business_profile_id == business_profile.id
            else
              _ -> false
            end
          :influencer ->
            with {:ok, influencer_profile} <- get_influencer_profile(current_user.id) do
              booking.influencer_profile_id == influencer_profile.id
            else
              _ -> false
            end
        end

        if has_access do
          conn
          |> json(%{
            success: true,
            data: format_booking(booking)
          })
        else
          conn
          |> put_status(:forbidden)
          |> json(%{success: false, error: "Access denied"})
        end

      {:error, _error} ->
        conn
        |> put_status(:not_found)
        |> json(%{success: false, error: "Booking not found"})
    end
  end

  defp get_business_profile(user_id) do
    case BusinessProfile.read() |> Enum.find(&(&1.user_id == user_id)) do
      nil -> {:error, :business_profile_not_found}
      profile -> {:ok, profile}
    end
  end

  defp get_influencer_profile(user_id) do
    case InfluencerProfile.read() |> Enum.find(&(&1.user_id == user_id)) do
      nil -> {:error, :influencer_profile_not_found}
      profile -> {:ok, profile}
    end
  end

  defp format_booking(booking) do
    %{
      id: booking.id,
      business_profile_id: booking.business_profile_id,
      influencer_profile_id: booking.influencer_profile_id,
      package_id: booking.package_id,
      status: booking.status,
      total_amount: booking.total_amount,
      platform_fee: booking.platform_fee,
      influencer_amount: booking.influencer_amount,
      currency: booking.currency,
      brief: booking.brief,
      requirements: booking.requirements,
      deadline: booking.deadline,
      created_at: booking.created_at,
      updated_at: booking.updated_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end