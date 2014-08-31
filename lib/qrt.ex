defmodule Qrt do

  def scenario do
    %{iterations: nil, paths: nil, rest_time: 10_000, f_test: nil}
  end

  def results do
    %{num: 0, avg_time: 0, percent_success: 0}
  end

  def accumulator do
    %{cummulative_time: 0, success: 0, count: 0}
  end

  def test do
    %{time: nil, success: false}
  end

  # in: Map that configures the test
  # out: csv file with results
  def run(scenario) do
    {date, _} = System.cmd("date", ["+%Y-%m-%d_%H-%M-%S"])
    output = File.open! "results-#{String.strip(date, ?\n)}.csv", [:utf8, :write]
    # List of tests, value is mumber of simultaneous users in each test
    # Tasks simulate N users hitting API at the same time.
    scenario[:iterations]
    |> Enum.map(fn(num) ->
      IO.puts "== running #{num} iterations"
      run_test(num, scenario)
    end)
    |> Enum.map(fn(results) ->
      IO.puts output, "#{results[:num]}, #{results[:avg_time]}, #{results[:percent_success]}"
    end)
    |> Enum.uniq
  end

  # Do test, does n calls of test function, returns results struct (one line of the csv)
  # in: Number of iterations in this test, & config map
  # out: results map representing one line in the csv file
  def run_test(num, scenario) do
    test = scenario[:f_test]
    Enum.map(1..num, fn(x)->
      Task.async(fn->
        test.(scenario)
      end)
    end)
    |> Enum.map(&Task.await/1)
    |> List.flatten
    |> Enum.reduce(accumulator, fn(test, acc)-> #accumulates the results
        success = cond do
          test[:success] -> acc[:success] + 1 #increment counter
          true -> acc[:success] #don't increment
        end
        %{acc |
          count: acc[:count]+1,
          success: success,
          cummulative_time: acc[:cummulative_time] + test[:time]
          }
      end)
    |> stats(num)
    |> sleep_pipe(scenario)
  end

  def stats(acc, num) do
    %{results |
      num: num,
      avg_time: acc[:cummulative_time] / acc[:count],
      percent_success: acc[:success] / acc[:count]
    }
  end

  def sleep_pipe(context, scenario) do
    :timer.sleep(scenario[:rest_time]) #wait before next run
    context
  end


end
