defmodule TagzUp.Bookings do
  use Ash.Domain

  resources do
    resource TagzUp.Bookings.Booking
    resource TagzUp.Bookings.Payment
    resource TagzUp.Bookings.Proof
    resource TagzUp.Bookings.Dispute
  end
end