defmodule Example do

  def config do
    %{ Qrt.scenario |
    iterations: [10, 20, 30, 40, 50, 60, 70, 80, 90, 100],
    paths: nil,
    rest_time: 1_000,
    f_test: &ping_localhost/1   #takes scenario as only parameter
    }
  end

  def run do
    Qrt.run(config)
  end

  def ping_localhost(scenario) do
    tstart = :erlang.now()
    {output, status} = System.cmd("ping", ["-a", "-c 1", "127.0.0.1"])
    tend = :erlang.now()
    success = case status do
      0 -> true
      _ -> false
    end
    %{Qrt.test |
      time: :timer.now_diff(tend, tstart) / 1000000,
      success: success
    }
    # |> IO.inspect
  end

end
