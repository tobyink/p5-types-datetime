# NAME

Types::DateTime - type constraints and coercions for datetime objects

# VERSION

version 0.001

# SYNOPSIS

```perl
package FroobleGala;

use Moose;
use Types::DateTime -all;

has start_date => (
   is      => 'ro',
   isa     => DateTimeUTC->plus_coercions( Format['ISO8601'] ),
   coerce  => 1,
);
```

# DESCRIPTION

[Types::DateTime](https://metacpan.org/pod/Types::DateTime) is a type constraint library suitable for use with
[Moo](https://metacpan.org/pod/Moo)/[Moose](https://metacpan.org/pod/Moose) attributes, [Kavorka](https://metacpan.org/pod/Kavorka) sub signatures, and so forth.

## Types

This module provides some type constraints broadly compatible with
those provided by [MooseX::Types::DateTime](https://metacpan.org/pod/MooseX::Types::DateTime), plus a couple of extra
type constraints.

- `DateTime`

    A class type for [DateTime](https://metacpan.org/pod/DateTime). Coercions from:

    - from `Num`

        Uses ["from\_epoch" in DateTime](https://metacpan.org/pod/DateTime#from_epoch). Floating values will be used for sub-second
        precision, see [DateTime](https://metacpan.org/pod/DateTime) for details.

    - from `HashRef`

        Calls ["new" in DateTime](https://metacpan.org/pod/DateTime#new) or ["from\_epoch" in DateTime](https://metacpan.org/pod/DateTime#from_epoch) as appropriate, passing
        the hash as arguments.

    - from `Now`

        Uses ["now" in DateTime](https://metacpan.org/pod/DateTime#now).

    - from `InstanceOf['DateTime::Tiny']`

        Inflated using ["DateTime" in DateTime::Tiny](https://metacpan.org/pod/DateTime::Tiny#DateTime).

- `Duration`

    A class type for [DateTime::Duration](https://metacpan.org/pod/DateTime::Duration). Coercions from:

    - from `Num`

        Uses ["new" in DateTime::Duration](https://metacpan.org/pod/DateTime::Duration#new) and passes the number as the `seconds`
        argument.

    - from `HashRef`

        Calls ["new" in DateTime::Duration](https://metacpan.org/pod/DateTime::Duration#new) with the hash entries as arguments.

- `Locale`

    A class type for [DateTime::Locale](https://metacpan.org/pod/DateTime::Locale). Coercions from:

    - from `Str`

        The string is treated as a language tag (e.g. `en` or `he_IL`) and
        given to ["load" in DateTime::Locale](https://metacpan.org/pod/DateTime::Locale#load).

    - from `InstanceOf['Locale::Maketext']`

        The `Locale::Maketext/language_tag` attribute will be used with
        ["load" in DateTime::Locale](https://metacpan.org/pod/DateTime::Locale#load).

- `TimeZone`

    A class type for [DateTime::TimeZone](https://metacpan.org/pod/DateTime::TimeZone). Coercions from:

    - from `Str`

        Treated as a time zone name or offset. See ["USAGE" in DateTime::TimeZone](https://metacpan.org/pod/DateTime::TimeZone#USAGE)
        for more details on the allowed values.

        Delegates to ["new" in DateTime::TimeZone](https://metacpan.org/pod/DateTime::TimeZone#new) with the string as the `name`
        argument.

- `Now`

    Type constraint with only one allowed value, the string "now".

    This is exported for compatibility with [MooseX::Types::DateTime](https://metacpan.org/pod/MooseX::Types::DateTime), which
    exports such a constraint, even though it is not documented.

- `DateTimeWithZone`

    A subtype of `DateTime` for objects with a defined (non-floating) time
    zone.

    This type constraint inherits its coercions from `DateTime`.

- `` DateTimeWithZone[`a] ``

    The `DateTimeWithZone` type constraint may be parameterized with a
    [DateTime::TimeZone](https://metacpan.org/pod/DateTime::TimeZone) object, or a string that can be coerced into one.

    ```perl
    has start_date => (
       is      => 'ro',
       isa     => DateTimeWithZone['Europe/London'],
       coerce  => 1,
    );
    ```

    This type constraint inherits its coercions from `DateTime`, and will
    additionally call ["set\_time\_zone" in DateTime](https://metacpan.org/pod/DateTime#set_time_zone) to shift objects into the
    correct timezone.

- `DateTimeUTC`

    Shortcut for `DateTimeWithZone["UTC"]`.

## Named Coercions

It is hoped that Type::Tiny will help avoid the proliferation of
modules like [MooseX::Types::DateTimeX](https://metacpan.org/pod/MooseX::Types::DateTimeX),
[MooseX::Types::DateTime::ButMaintained](https://metacpan.org/pod/MooseX::Types::DateTime::ButMaintained), and
[MooseX::Types::DateTime::MoreCoercions](https://metacpan.org/pod/MooseX::Types::DateTime::MoreCoercions). It makes it very easy to add
coercions to a type constraint at the point of use:

```perl
has start_date => (
   is      => 'ro',
   isa     => DateTime->plus_coercions(
      InstanceOf['MyApp::DT'] => sub { $_->to_DateTime }
   ),
   coerce  => 1,
);
```

Even easier, this module exports some named coercions.

- `` Format[`a] ``

    May be passed an object providing a `parse_datetime` method, or a
    class name from the `DateTime::Format::` namespace (upon which
    `new` will be called).

    For example:

    ```
    DateTime->plus_coercions( Format['ISO8601'] )
    ```

    Or:

    ```perl
    DateTimeUTC->plus_coercions(
       Format[
          DateTime::Format::Natural->new(lang => 'en')
       ]
    )
    ```

- `` Strftime[`a] ``

    A pattern for serializing a DateTime object into a string using
    ["strftime" in DateTime](https://metacpan.org/pod/DateTime#strftime).

    ```
    Str->plus_coercions( Strftime['%a %e %b %Y'] );
    ```

- `ToISO8601`

    A coercion for serializing a DateTime object into a string using
    ["iso8601" in DateTime](https://metacpan.org/pod/DateTime#iso8601).

    ```
    Str->plus_coercions( ToISO8601 );
    ```

# NAME

Types::DateTime - type constraints and coercions for datetime objects

# BUGS

Please report any bugs to
[http://rt.cpan.org/Dist/Display.html?Queue=Types-DateTime](http://rt.cpan.org/Dist/Display.html?Queue=Types-DateTime).

# SEE ALSO

[MooseX::Types::DateTime](https://metacpan.org/pod/MooseX::Types::DateTime),
[Type::Tiny::Manual](https://metacpan.org/pod/Type::Tiny::Manual),
[DateTime](https://metacpan.org/pod/DateTime),
[DateTime::Duration](https://metacpan.org/pod/DateTime::Duration),
[DateTime::Locale](https://metacpan.org/pod/DateTime::Locale),
[DateTime::TimeZone](https://metacpan.org/pod/DateTime::TimeZone).

# AUTHOR

Toby Inkster <tobyink@cpan.org>.

# COPYRIGHT AND LICENCE

This software is copyright (c) 2014, 2017 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

# AUTHOR

Toby Inkster <tobyink@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
