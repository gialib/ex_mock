# ExMock
A mocking libary for the Elixir language.

We use the Erlang [meck library](https://github.com/eproxus/meck) to provide
module mocking functionality for Elixir. It uses macros in Elixir to expose the
functionality in a convenient manner for integrating in Elixir tests.

## Installation
First, add mock to your `mix.exs` dependencies:

```elixir
def deps do
  [{:ex_mock, "~> 0.1.1", only: :test}]
end
```

and run `$ mix deps.get`.

## Example
The ExMock library provides the `with_mock` macro for running tests with
mocks.

For a simple example, if you wanted to test some code which calls
`HTTPotion.get` to get a webpage but without actually fetching the
webpage you could do something like this.

```` elixir
defmodule MyTest do
  use ExUnit.Case, async: false

  import ExMock

  test "test_name" do
    with_mock HTTPotion, [get: fn(_url) -> "<html></html>" end] do
      HTTPotion.get("http://example.com")
      # Tests that make the expected call
      assert called HTTPotion.get("http://example.com")
    end
  end
end
````

And you can mock up multiple modules with `with_mocks`.

`opts` List of optional arguments passed to meck. `:passthrough` will
passthrough arguments to the original module. Pass `[]` as `opts` if you don't
need this.

```` elixir
defmodule MyTest do
  use ExUnit.Case, async: false

  import ExMock

  test "multiple mocks" do
    with_mocks([
      {HashDict,
       [],
       [get: fn(%{}, "http://example.com") -> "<html></html>" end]},
      {String,
       [],
       [reverse: fn(x) -> 2*x end,
        length: fn(_x) -> :ok end]}
    ]) do
      assert HashDict.get(%{}, "http://example.com") == "<html></html>"
      assert String.reverse(3) == 6
      assert String.length(3) == :ok
    end
  end
end
````

An additional convenience macro `test_with_mock` is supplied which
internally delegates to `with_mock`. Allowing the above test to be
written as follows:

```` elixir
defmodule MyTest do
  use ExUnit.Case, async: false

  import ExMock

  test_with_mock "test_name", HTTPotion,
    [get: fn(_url) -> "<html></html>" end] do
    HTTPotion.get("http://example.com")
    assert called HTTPotion.get("http://example.com")
  end
end
````

The `test_with_mock` macro can also be passed a context argument
allowing the sharing of information between callbacks and the test

```` elixir
defmodule MyTest do
  use ExUnit.Case, async: false

  import ExMock

  setup do
    doc = "<html></html>"
    {:ok, doc: doc}
  end

  test_with_mock "test_with_mock with context", %{doc: doc}, HTTPotion, [],
    [get: fn(_url, _headers) -> doc end] do

    HTTPotion.get("http://example.com", [foo: :bar])
    assert called HTTPotion.get("http://example.com", :_)
  end
end
````

The `with_mock` creates a mock module. The keyword list provides a set
of mock implementation for functions we want to provide in the mock (in
this case just `get`). Inside `with_mock` we exercise the test code
and we can check that the call was made as we expected using `called` and
providing the example of the call we expected (the second argument `:_` has a
special meaning of matching anything).

You can also pass the option `:passthrough` to retain the original module
functionality. For example
```` elixir
defmodule MyTest do
  use ExUnit.Case, async: false
  import ExMock

  test_with_mock "test_name", IO, [:passthrough], [] do
    IO.puts "hello"
    assert called IO.puts "hello"
  end
end
````

You can mock functions that return different values:

```` elixir
defmodule MyTest do
  use ExUnit.Case, async: false
  
  import Mock
  
  test "mock functions with multiple returns" do
    with_mocks(HTTPotion, [
      get: fn
        "http://example.com" -> "<html>Hello from example.com</html>"
        "http://example.org" -> "<html>example.org says hi</html>"
      end
    ]) do
      assert HTTPotion.get("http://example.com") == "<html>Hello from example.com</html>"
      assert HTTPotion.get("http://example.org") == "<html>example.org says hi</html>"
    end
  end
end
````

Currently, mocking modules cannot be done asynchronously, so make sure that you
are not using `async: true` in any module where you are testing.

Also, because of the way mock overrides the module, it must be defined in a
seperate file from the test file.

## Tips
The use of mocking can be somewhat controversial. I personally think that it
works well for certain types of tests. Certainly, you should not overuse it. It
is best to write as much as possible of your code as pure functions which don't
require mocking to test. However, when interacting with the real world (or web
services, users etc.) sometimes side-effects are necessary. In these cases,
mocking is one useful approach for testing this functionality.

Also, note that ExMock has a global effect so if you are using ExMocks in multiple
tests set `async: false` so that only one test runs at a time.

## Help
Open an issue.

## Suggestions
I'd welcome suggestions for improvements or bugfixes. Just open an issue.
