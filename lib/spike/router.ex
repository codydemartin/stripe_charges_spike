defmodule Spike.Router do
  use Plug.Router

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "/home" do
    {:ok, test_json} = Jason.encode(%{found: "yes"})

    conn
    |> Plug.Conn.resp(200, test_json)
    |> Plug.Conn.send_resp()
  end

  post "/customer" do
    %{
      "email" => email
    } = conn.body_params

    {:ok, info_json} =
      Spike.create_stripe_customer(email)
      |> Jason.encode()

    IO.inspect(info_json)

    conn
    |> Plug.Conn.resp(200, info_json)
    |> Plug.Conn.send_resp()
  end

  post "/charge" do
    %{
      "customer_id" => customer_id
    } = conn.body_params

    {:ok, json} =
      Spike.create_charge(customer_id)
      |> Jason.encode()

    conn
    |> Plug.Conn.resp(200, json)
    |> Plug.Conn.send_resp()
  end
end
