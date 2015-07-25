# LogJam

LogJam is a library that attempts to allow for the aggregation and the
distribution of logging facilities across a range of classes. Goals in
creating this library were...

   * Easy of use. Fall back on defaults as much as possible and allow the
     functionality to be integrated and used with the least amount of work.

   * Flexibility. After easy of use is taken into consideration it should be
     possible to use the library in a more advanced fashion if that is called
     for.

   * Minimize the code to use it. It shouldn't require a great deal of code to
     deploy or use the facilities and there should be no code required to pass
     entities such as loggers around.

   * Usable in libraries. I found myself writing a lot of common logging code
     when writing libraries and application and wanted to abstract that out. I
     wanted to minimize the burden this placed on library users at the same
     time.

## Release Log

 * v1.2.0: This version sees a major rewrite of the internals of the library
   while attempting to retain backward compatibility. Library configuration
   has been changed to get greater flexibility and to allow for the logging
   configuration to be folded into a larger configuration file. The tests were
   all changed to rspec and more extensive tests written.

## Configuration & Setup

The simplest setup to use with this library is to create a YAML file in the
called ```logging.yml```, either in the current working directory or in a
subdirectory of the working directory called ```config```. Place the following
contents into this file...

    development:
      loggers:
      - default: true
        file: STDOUT
        name: devlog
    production:
      loggers:
      - default: true
        file: ./logs/production.log
        name: prodlog
    test:
      loggers:
      - default: true
        file: STDOUT
        name: testlog

By doing this you've now created a configuration that is environment dependent
and that the LogJam library will automatically pick up. When run in the
development (the default environment if no other is specified) or test
environments your application will now log to the standard output stream. For
the production environment the logging output will be written to a file called
```production.log``` which will be in the ```logs``` subdirectory.

The settings covered in the example configuration above are just some of the
parameters recognised for the definition of a logger. Here is a more complete
list of parameters that are used when creating loggers...

 * default: A boolean indicating whether this logger is the default (i.e. the
   one to be used when no other explicitly fits the bill). Only one logger
   should be declared as a default.

 * datetime_format: The date/time format to be used by the logger. See the
   documentation for the standard Ruby Logger class for more details.

 * file: The path and name of the file that logging details will be written to.
   Two special values are recognised in this value. STDOUT and STDERR are
   translated to mean the standard output or error streams respectively.

 * level: The logging level to set on the logger. Must be one of DEBUG, INFO,
   WARN, ERROR, FATAL or UNKNOWN. If not explicitly specified this defaults
   to DEBUG.

 * max_size: When rotation is set to an integer value this value can be set to
   indicate the maximum permitted file size for a log file in bytes.

 * name: The name to associate with the logger. This allows loggers to be tied
   to classes or for the creation of aliases that tie multiple names to a single
   logger. Note that you should always use Strings (and not Symbols) when
   specifying aliases.

 * rotation: The frequency with which the log file is rotated. This may be an
   integer to indicate how many old log files are retained or may be a String
   such as "daily", "weekly" or "monthly".

A note on logger names. Logger names (including alias names) aren't hierarchical
and should be unique. Note that you may specify multiple logger definitions if
you wish, which would look like this...

    development:
      loggers:
      - default: true
        file: STDOUT
        name: devlog
      - file: ./logs/development.log
        name: filelog

In addition to specifying logger definitions you can also specify logger
aliases. This is essentially a mechanism to allow a single logger to be
available under multiple names and a configuration including an alias definition
might look as follows...

    development:
      loggers:
      - default: true
        file: STDOUT
        name: devlog
      aliases:
        database: devlog

If you don't provide a logging configuration then the LogJam library will fall
back on creating a single default logger that writes everything to the standard
output stream.

## Logging With The Library

The stated goals of the LogJam library are to avoid the need to pass Logger
instances around while still allowing potentially complex configuration with a
minimum of code. The first step in this process has been covered in the
Configuration & Setup section in which it's explained how to configure logging
from a single Hash or file. This section will provide details on how to deploy
loggers to various classes.

The LogJam library extends the object class to make access to a logger available
at both the class and the instance level. The obtain a logger object you can
make a call to the ```#log()``` method. If you haven't explicitly configured a
logger for a class this will return an instance of the default logger. A version
of this method is also available at the instance level.

If you want to get more advanced and configure a particular logger for a
specific class or group of classes then you have to explicitly set the logger
on those classes. To do that you define multiple loggers in your configuration
and then make a call to the ```#set_logger_name()``` method for the affected
class. For example, if you defined a logger called string_logger that you wanted
to use just for String objects you could do that like so...

    String.set_logger_name("string_logger")

With your code you can obtain a logger instance and then use the method common
to Ruby's Logger class on the object returned. So, to log a statement at the
info level in a piece of code you would do something like this...

    log.info("This is a statement that I am logging.")

Consult the documentation of the Ruby Logger class for more information on the
methods and logging levels available.

## Advanced Usage

The hope would be that this library can be used in the creation of other
libraries and allow for control of the logging generated by those libraries
without having to dig into the workings of the library or to pass around Logger
instances as constructor parameters or static data. In this case I recommend
explicitly declaring logger names for your library classes and making the name
that the library uses available with the library documentation so that the
libraries logging can be switched off or on as needed.

It's intended that, in general, the configure() method on the LogJam module
should only be called once. Calling it a second time will clear all existing
logging configuration and set up. This may or may not be an issue depending on
whether you decide to cache logger inside class instances instead of always
accessing them through the class level accessor.

The Logger instance returned from a LogJam are intended to be fully compatible
with the class defined within the standard Ruby Logger library. If you need to
change elements, such as the formatter, you should just do so on the logger in
the normal fashion. If you define multiple Logger instances then you will have
to change each individually.

Using the log=() method that is added to each class by the LogJam facilities it
is possible to change the Logger being used. If you want to use this method
please note that changing a Logger that is created via an alias will change the
original Logger and thereby affect all classes that make use of that Logger (and
not necessarily just the one making the change). If you want to do this give the
class it's own logger instance.

Finally, any logger can be fetched from the library using it's name and making
a call to the LogJam.get_logger() method. Note if you omit the name or pass in
nil you will retrieve the libraries default logger.

## Example Configurations

This section contains some example configurations. A short explanation is given
for each configuration and then the configuration itself in Hash, YAML and JSON
formats is provided.

This represents the most basic configuration possible. In passing an empty Hash
to the configure method the system creates a single, default logger that writes
everything on the standard output stream...

Hash
```
   {}
```

YAML
```
   {}
```

JSON
```
   {}
```

The following simple configuration writes all logging output to a file called
application.log in the current working directory. If a logging level is not
explicitly specified then DEBUG is the default...

Hash
```
   {:loggers => [{:default => true, :file => "application.log"}]}
```

YAML
```
   :loggers:
   - :default: true
     :file: application.log
```

JSON
```
   {"loggers": {"default": true, "file": "application.log"}}
```

This configuration declares two loggers. The first is called 'silent' and will
log nothing. The silent logger is the default and so will be used for any class
that doesn't have an explicitly named logger. The second is called 'verbose' and
logs everything from the debug level up on the standard output stream. The
configuration also declares an alias pointing the name 'database' to refer to
the verbose logger. An class that declares it uses the 'database' logger will
generate output while all others will be silenced.

Hash
```
   {:loggers => [{:default => true,
                  :file    => "STDOUT",
                  :level   => "UNKNOWN",
                  :name    => "silent"},
                 {:file    => "STDOUT",
                  :name    => "verbose"}],
    :aliases => {"database" => "verbose"}}
```

YAML
```
   :loggers:
   - :default: true
     :file: STDOUT
     :level: UNKNOWN
     :name: silent
   - :file: STDOUT
     :name: verbose
   :aliases:
     database: verbose
```

JSON
```
   {"loggers": [{"default":true,
                 "file": "STDOUT",
                 "level": "UNKNOWN",
                 "name": "silent"},
                {"file": "STDOUT",
                 "name": "verbose"}],
    "aliases": {"database":"verbose"}}
```

The following configuration can be used as an example of how to drive logging
from different parts of the code to different destinations. The configuration
declares two loggers which deliver their output to two different log files and
then declares aliases for those loggers that can be used to divide up the
logging coming from different areas of the code.

Hash
```
   {:loggers => [{:default => true,
                  :file    => "./log/main.log",
                  :name    => "main"},
                 {:file    => "./log/secondary.log",
                  :name    => "secondary"}],
    :aliases => {"database"   => "secondary",
                 "model"      => "secondary",
                 "controller" => "main"}}
```

YAML
```
   :loggers:
   - :default: true
     :file: ./log/main.log
     :name: main
   - :file: ./log/secondary.log
     :name: secondary
   :aliases:
     database: secondary
     model: secondary
     controller: main
```

JSON
```
   {"loggers": [{"default":true,
                 "file": "./log/main.log",
                 "name": "main"},
                {"file": "./log/secondary.log",
                 "name": "secondary"}],
    "aliases": {"database":"secondary",
                "model": "secondary",
                "controller": "main"}}
```

## Testing

LogJam uses the RSpec Ruby library for testing. The best approach to running
the tests are to create a new gemset (assuming you're using RVM), do a bundle
install on this gemset from within the LogJam root directory and then use a
command such as the following to run the tests...

```
    $> rspec
```

Individual tests can be run by appending the path to the file that you want to
execute after the ```rspec``` command. For example...

```
   $> rake spec/logjam_spec.rb
```

...would run only the the tests in the logjam_spec.rb test file.
