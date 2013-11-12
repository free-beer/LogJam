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

## Configuration & Setup

To explicitly configure the settings LogJam you make a call to the
LogJam#configure() method. This method takes a single parameter which should be
either a String, a Hash, an IO object or nil.

If you pass a String in this is expected to contain the path and name of a file
that contains the logging configuration. Logging configuration files can be
provided in either YAML or JSON format. If you pass an IO object this is
expected to be the source of the configuration and, again, this configuration
should be in either YAML or JSON format. In either case, where a String or IO
is specified, the data read must be translatable into a Hash, which brings us
to the other type that the LogJam#configure() method accepts as a parameter.

A Hash passed to the configure() method is expected to contain a set of values
that can be converted into a logging set up. Passing an empty Hash will result
in set up containing a single, universal logger attached to the standard output
stream being created and used by all classes that have LogJam functionality.

The Hash passed to the configure() method can contain two keys that the library
will recognise and use. The first of these is 'loggers', in either Symbol or
String form. The value under the loggers key is expected to be an Array
containing zero or more logger definitions. An individual logger definition is
itself a Hash in which the following keys are recognised (either as Strings or
Symbols) - default, datetime_format, file, level, max_size, name and rotation.
The meanings applied to these keys are as follows...

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
   indicate the maximum permitted file size for a log file.

 * name: The name to associate with the logger. This allows loggers to be tied
   to classes or for the creation of aliases that tie multiple names to a single
   logger. Note that you should always use Strings (and not Symbols) when
   specifying aliases.

 * rotation: The frequency with which the log file is rotated. This may be an
   integer to indicate how many old log files are retained or may be a String
   such as "daily", "weekly" or "monthly".

A note on logger names. Logger names (including alias names) aren't hierarchical
and should be unique.

The second key recognised in the configuration Hash is 'aliases', again as
either a String or Symbol. The value under the aliases key is expected to be a
Hash that maps String keys to String values. The key values are expected to be
alias names and the mapped values are expected to be the name of a logger
declared in the logger section. An entry in the aliases Hash creates an alias
for an existing logger under a different name.

The final parameter option when calling LogJam#configure() is to pass a nil to
the method. If you pass nil to the configure method it behaves in a slightly
different fashion. In this case the method searches for a configuration file
that it can use given a default set of files names (logging.yaml, logging.yml
and logging.json in the current working directory and in a subdirectory of the
current working directory called config). The first of these files that it finds
it attempts to use as configuration for the logging set up. If it doesn't find
a configuration file then this type of call becomes equivalent to passing an
empty Hash to the configure() method. As of version 1.1.0 the library includes
an implicit call to LogJam#configure(nil) removing the need to do this
explicitly in your own code.

Note that you can call LogJam#configure multiple times, with each successive
call overwriting and replacing the details of previous calls. See the end of
this document for some example configurations.

## Logging With The Library

The stated goals of the LogJam library are to avoid the need to pass Logger
instances around while still allowing potentially complex configuration with a
minimum of code. The first step in this process has been covered in the
Configuration & Setup section in which it's explained how to configure logging
from a single Hash or file. This section will provide details on how to deploy
loggers to various classes.

The LogJam library works by providing an extension to any class that uses it
that provides access to the logger to be used by the class. As of version 1.1.0
LogJam applies itself as an extension to the Ruby Object class, making the
logging facilities it provides available in any object. Prior to v1.1.0 you had
to make a call the apply() method of the LogJam module inside your class
definition. A typical call of this type might look like...

```
   # Apply logging facilties to my class.
   LogJam.apply(self, "my_logger")
```
   
This option remains available for backward compatibility but is no longer
needed. A line like this would appear somewhere inside the definition for the
class that will use logging. The first parameter to the call is the class that
is to be extended with the LogJam functionality. The second parameter is the
name of the logger that the class will use. Note that this parameter is optional
and, if notspecified or if a matching logger does not exist, the class will fall
back in using the default logger.

From version 1.1.0 onward you no longer need to call apply. Instead LogJams
logging facilities are available in all objects. This change means that all
classes use the default logger as standard. If you want to continue to use an
explitictly named logger on a per class basis you can make a call to the
LogJam#set_logger_name() method within your class definitions. This is similar
in nature to how the apply method was used and so would look something like the
following...

```
   # Use an explicitly named logger for my class.
   set_logger_name "my_logger"
```

LogJams logging facilities consist of two class level methods (one called log()
and one called log=()) and an instance level method called log(). The log()
methods retrieve the Logger instance to be used by the class instances. The
log=() method allows the Logger instance associated with a class to be altered.
You should take care when assigning a logger in this fashion as assigning it
on one class may have an impact on many classes (e.g. if there is only a single
default logger defined in configuration).

The following complete (although contrived) example gives an overview of how
this would work...

```
   require 'rubygems'
   require 'logjam'
   
   class Writer
      def initialize(stream=STDOUT)
         @stream = stream
      end
      
      def echo(message)
         log.debug("Echoed: #{message}")
         @stream.puts message
      end
   end
   
   begin
      LogJam.configure({:loggers => [{:name => "echo",
                                      :file => "echo.log"}]})
                                      
      writer = Writer.new
      writer.echo "This is a string containing my message."
   rescue => error
      puts "ERROR: #{error}\n" + error.backtrace.join("\n")
   end
```

In this example we create a Writer class that can echo a String on a stream. In
doing this it also logs the message echoed at the debug level. We can simply
call the log() method to get the class logger.

In the later section of the code we configure the LogJam system to have a single
Logger that writes to the echo.log file. We then create a Writer instance and
use it to write a simple message. This message should appear on the standard
output stream and be logged to the echo.log file.
 
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

LogJam uses the minitest Ruby library for testing. The best approach to running
the tests are to create a new gemset (assuming you're using RVM), do a bundle
install on this gemset from within the LogJam root directory and then use a
command such as the following to run the tests...

```
    $> rake test:unit
```

Individual tests can be run by including a definition for TESTS which contains
a comma separated_list of the tests to be run. For example...

```
   $> rake test:unit TESTS=object,apply
```

...would run only the object and apply tests.