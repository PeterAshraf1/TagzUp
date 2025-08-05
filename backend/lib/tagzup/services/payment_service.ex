defmodule TagzUp.Services.PaymentService do
  @moduledoc """
  Service for handling payments via Stripe and other payment providers
  """
  
  require Logger
  alias TagzUp.Bookings.{Booking, Payment}

  def create_payment_intent(booking_id, payment_method \\ "card") do
    case Booking.read(booking_id) do
      {:ok, booking} ->
        # Create Stripe payment intent
        case create_stripe_payment_intent(booking, payment_method) do
          {:ok, payment_intent} ->
            # Create payment record
            payment_params = %{
              booking_id: booking.id,
              stripe_payment_intent_id: payment_intent["id"],
              amount: booking.total_amount,
              currency: String.downcase(booking.currency),
              status: :processing,
              payment_method: payment_method,
              metadata: %{
                stripe_client_secret: payment_intent["client_secret"]
              }
            }

            case Payment.create(payment_params) do
              {:ok, payment} ->
                {:ok, %{
                  payment_id: payment.id,
                  client_secret: payment_intent["client_secret"],
                  amount: booking.total_amount,
                  currency: booking.currency
                }}
              
              {:error, error} ->
                Logger.error("Failed to create payment record: #{inspect(error)}")
                {:error, "Failed to create payment record"}
            end
          
          {:error, error} ->
            Logger.error("Failed to create Stripe payment intent: #{inspect(error)}")
            {:error, "Failed to create payment intent"}
        end
      
      {:error, _error} ->
        {:error, "Booking not found"}
    end
  end

  def confirm_payment(payment_id, stripe_payment_intent_id) do
    case Payment.read(payment_id) do
      {:ok, payment} ->
        if payment.stripe_payment_intent_id == stripe_payment_intent_id do
          # Verify payment with Stripe
          case verify_stripe_payment(stripe_payment_intent_id) do
            {:ok, payment_intent} when payment_intent["status"] == "succeeded" ->
              # Update payment status
              Payment.update_status(%{
                id: payment.id,
                status: :succeeded,
                metadata: Map.merge(payment.metadata || %{}, %{
                  stripe_payment_intent: payment_intent
                })
              })
              
              # Update booking status
              Booking.update_status(%{
                id: payment.booking_id,
                status: :paid,
                started_at: DateTime.utc_now()
              })
              
              {:ok, %{status: :succeeded}}
            
            {:ok, payment_intent} ->
              # Payment not succeeded yet
              Payment.update_status(%{
                id: payment.id,
                status: String.to_atom(payment_intent["status"]),
                metadata: Map.merge(payment.metadata || %{}, %{
                  stripe_payment_intent: payment_intent
                })
              })
              
              {:ok, %{status: String.to_atom(payment_intent["status"])}}
            
            {:error, error} ->
              Payment.update_status(%{
                id: payment.id,
                status: :failed,
                failure_reason: inspect(error)
              })
              
              {:error, "Payment verification failed"}
          end
        else
          {:error, "Payment intent ID mismatch"}
        end
      
      {:error, _error} ->
        {:error, "Payment not found"}
    end
  end

  def process_payout(booking_id) do
    case Booking.read(booking_id) do
      {:ok, booking} when booking.status == :completed ->
        # In a real implementation, this would create a Stripe transfer
        # to the influencer's connected account
        Logger.info("Processing payout for booking #{booking.id}: #{booking.influencer_amount} #{booking.currency}")
        
        # For now, just log the payout
        {:ok, %{
          amount: booking.influencer_amount,
          currency: booking.currency,
          status: :processed
        }}
      
      {:ok, _booking} ->
        {:error, "Booking not ready for payout"}
      
      {:error, _error} ->
        {:error, "Booking not found"}
    end
  end

  defp create_stripe_payment_intent(booking, payment_method) do
    # In a real implementation, this would call Stripe API
    # For now, simulate the response
    {:ok, %{
      "id" => "pi_" <> generate_random_string(24),
      "client_secret" => "pi_" <> generate_random_string(24) <> "_secret_" <> generate_random_string(16),
      "amount" => trunc(Decimal.to_float(booking.total_amount) * 100), # Stripe uses cents
      "currency" => String.downcase(booking.currency),
      "status" => "requires_payment_method"
    }}
  end

  defp verify_stripe_payment(payment_intent_id) do
    # In a real implementation, this would call Stripe API to retrieve payment intent
    # For now, simulate successful payment
    {:ok, %{
      "id" => payment_intent_id,
      "status" => "succeeded",
      "amount_received" => :rand.uniform(10000),
      "currency" => "egp"
    }}
  end

  defp generate_random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
    |> String.replace(~r/[^a-zA-Z0-9]/, "")
  end
end