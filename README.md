# Spread

Spread is a simple command line application to calculate the spread-to-benchmark and spread-to-curve of various corporate bonds and their government bond benchmarks. 

[Documentation](https://ryantaylor.github.io/spread/)

## Installation

```
$ git clone https://github.com/ryantaylor/spread.git
$ cd spread
$ gem install spread
```

If you want to use as a library, add this line to your application's Gemfile:

```ruby
gem 'spread'
```

And then execute:

    $ bundle

## Usage

The current state of the application is very simple. It accepts a path to a CSV file and prints comma-separated output to stdout.

    $ spread sample_input.csv

The input CSV file is expected to be formatted as follows:

### Sample input

| bond   | type       | term        | yield |
|--------|------------|-------------|-------|
| C1     | corporate  | 10.3 years  | 5.30% |
| G1     | government | 9.4 years   | 3.70% |
| G2     | government | 12 years    | 4.80% |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Tech & Tradeoffs

This is my first experience with Ruby, so it's possible I may have sacrificed some best practices in order keep my time spent on the challenge at a reasonable level. However, I did my best to adhere to Ruby conventions as I understand them.

This is a very barebones application. Aside from the CSV library from Ruby's stdlib I didn't use any external code in the actual application. In order to ease development and provide some project structure, I used [Bundler](http://bundler.io/) to construct and manage the project. I chose [Minitest](https://github.com/seattlerb/minitest) as my testing framework and I use [Rake](https://github.com/ruby/rake) to build the project and run tests. Documentation was generated with [YARD](http://yardoc.org/).

Because I had to learn Ruby on top of actually writing the application, I had to make some tradeoffs, sacrificing robust functionality in the name of simplicity. If I had more time to refine and iterate, I would make the following changes:

* Add a proper command line interface.
* Fail gracefully on invalid input. I couldn't find a definitive source on how to properly handle exceptions in Ruby so I just let them throw without rescuing right now.
* Accept input straight from stdin instead of forcing the user to pass a file.
* Give the user more options for output. Split the two calculation functionalities into separate commands so they can be used independently.
* Separate the project into descrete library and application components for easier maintenance and greater usability. This includes updating the module structure to adhere to best practices.
* Separate calculations and equations into separate functions in the code in order to make unit testing easier, and find an alternative to using hard-coded puts commands for output. This is probably the biggest change in the context of this challenge because it would have made proper test coverage a whole lot easier.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

