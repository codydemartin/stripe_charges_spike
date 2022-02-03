defmodule Spike do
  def create_stripe_customer(email) do
    random_name = for _ <- 1..10, into: "", do: <<Enum.random('0123456789abcdef')>>

    {:ok, %Stripe.Customer{id: customer_id}} =
      %{
        name: random_name,
        email: email
      }
      |> Stripe.Customer.create()

    {:ok, %Stripe.Source{id: source_id}} = create_source()

    {:ok, %Stripe.Source{id: card_id}} = create_card(customer_id, source_id)
    create_payment_method(card_id, customer_id)

    %{cust_id: customer_id, source: source_id}
  end

  def create_source() do
    card_numbers = [
      4_242_424_242_424_242,
      4_000_056_655_665_556,
      5_555_555_555_554_444,
      6_011_111_111_111_117
    ]

    %{
      type: "card",
      card: %{
        skip_validation: true,
        number: Enum.random(card_numbers),
        exp_month: 1,
        exp_year: 2100
      }
    }
    |> Stripe.Source.create()
  end

  def create_card(customer_id, source_id) do
    Stripe.Card.create(%{
      customer: customer_id,
      source: source_id
    })
  end

  def create_payment_method(card, customer_id) do
    Stripe.PaymentMethod.attach(%{customer: customer_id, payment_method: card})
  end

  def create_charge(customer_id) do
    amounts = [
      1_000_00,
      100,
      1_000_000
    ]

    {:ok, %Stripe.Charge{id: id}} =
      %{
        amount: Enum.random(amounts),
        currency: "usd",
        customer: customer_id,
        description: "Test charge amounts."
      }
      |> Stripe.Charge.create()

    %{charge_id: id}
  end
end
