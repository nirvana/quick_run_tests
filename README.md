# quick_run_tests  Quick! Run some Tests!

A very simple project to quickly generate a simple load test, and collect statistics.

It runs a series of tests called iterations. An iteration is a number of simultaneas events. EG: they
could be requests to a webserver.  If your iterations are 1, 5, 10, 15 & 25, then the test effectively
sees what happens when 1, 5, 10, 15 and 25 people try to hit the webserver at the same time.

The actual test function is something you supply so it could be anything. It just needs to run the test,
collect the time for that indivual test and indicate whether it failed or not.

It returns a map in the form of:  %{time: nil, success: false}

For more sophisticated testing, we support passing a long a set of paths. These paths can be scenarios
or sample data for your tests.

The end result is a csv with stats for each load level.
  - Current stats:
    - Average time per request
    - %successful requests

At each load level the tests are run in parallel

## HowTo

  - Include quick_rest_test as a dependency
  - Configure your scenario
  - Qrt.run(scenario)

### Scenarios

  - Empty: Qrt.scenario()
  - Scenarios are maps with:
    - iterations_list: list of number of iterations to do, eg: [1, 10, 100]
    - paths: paths of documents with test data (optional)
    - rest_time: a pause between each load level (in milliseconds)
    - f_test/1: test function: eg: an WEB Request. input is paths, output is %{time: nil, success: false}
