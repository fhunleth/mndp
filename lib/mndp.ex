defmodule MNDP do
  @moduledoc """
  The Mikrotik Neighbor Discovery Protocol
  """

  defstruct [
    :header,
    :seq_no,
    :mac,
    :identity,
    :version,
    :platform,
    :uptime,
    :software_id,
    :board,
    :unpack,
    :ip_v6,
    :interface,
    :ip_v4
  ]

  def from_binary(<<header::16, seq_no::16, data::binary>>) do
    packet =
      parse(data, [{:header, header}, {:seq_no, seq_no}])
      |> List.flatten()
      |> Enum.map(&map/1)

    struct(__MODULE__, packet)
  end

  def parse(<<>>, acc), do: Enum.reverse(acc)

  def parse(<<type::16, length::16, data::binary>>, acc) do
    case data do
      <<data::bytes-size(length), rest::binary>> ->
        parse(rest, [{type, length, data} | acc])

      _ ->
        {:error}
    end
  end

  def map({1, _length, data}), do: {:mac, data}
  def map({5, _length, data}), do: {:identitiy, data}
  def map({7, _length, data}), do: {:version, data}
  def map({8, _length, data}), do: {:platform, data}

  def map({10, length, data}) do
    <<seconds::integer-little-size(length)-unit(8)>> = data
    {:uptime, seconds}
  end

  def map({11, _length, data}), do: {:software_id, data}
  def map({12, _length, data}), do: {:board, data}
  def map({14, _length, data}), do: {:unpack, data}
  def map({15, _length, data}), do: {:ip_v6, data}
  def map({16, _length, data}), do: {:interface, data}
  def map({17, _length, data}), do: {:ip_v4, data}
  def map({:seq_no, data}), do: {:seq_no, data}
  def map({:header, data}), do: {:header, data}
end
