use 5.008;
use strict;
use warnings;

package Types::DateTime;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use DateTime;
use DateTime::Duration;
use DateTime::Locale;
use DateTime::TimeZone;

use Module::Runtime qw( use_module );

use Type::Library -base, -declare => qw(
	DateTime Duration TimeZone Locale Now
	DateTimeWithZone DateTimeUTC
);
use Types::Standard qw( Num Str HashRef InstanceOf );
use Type::Utils;

# This stuff for compat with MooseX::Types::DateTime

class_type(DateTime, { class => 'DateTime' });
class_type(Duration, { class => 'DateTime::Duration' });
class_type(TimeZone, { class => 'DateTime::TimeZone' });
class_type(Locale,   { class => 'DateTime::Locale::root' });
enum(Now, ['now']);

coerce DateTime,
	from Num,     q{ 'DateTime'->from_epoch(epoch => $_) },
	from HashRef, q{ 'DateTime'->new(%{$_}) },
	from Now,     q{ 'DateTime'->now };

coerce Duration,
	from Num,     q{ 'DateTime::Duration'->new(seconds => $_) },
	from HashRef, q{ 'DateTime::Duration'->new(%{$_}) };

coerce TimeZone,
	from Str,     q{ 'DateTime::TimeZone'->new(name => $_) };

coerce Locale,
	from InstanceOf['Locale::Maketext'], q{ 'DateTime::Locale'->load($_->language_tag) },
	from Str,     q{ 'DateTime::Locale'->load($_) };

# Time zone stuff

declare DateTimeWithZone,
	as         DateTime,
	coercion   => 1,  # inherit coercions
	where      {          not($_ ->time_zone->isa(q/DateTime::TimeZone::Floating/))   },
	inline_as  { (undef, "not($_\->time_zone->isa(q/DateTime::TimeZone::Floating/))") },
	constraint_generator => sub {
		my $zone = TimeZone->assert_coerce(shift);
		sub { $_[0]->time_zone eq $zone };
	},
	coercion_generator => sub {
		my $parent = shift;
		my $child  = shift;
		my $zone   = TimeZone->assert_coerce(shift);
		
		my $c = 'Type::Coercion'->new(type_constraint => $child);
		$c->add_type_coercions(
			$parent->coercibles, sub {
				my $dt = DateTime->coerce($_);
				return $_ unless DateTime->check($dt);
				$dt->set_time_zone($zone);
				return $dt;
			},
		);
		$c;
	};

declare DateTimeUTC, as DateTimeWithZone['UTC'], coercion => 1;

# Stringy coercions. No sugar for this stuff ;-)

__PACKAGE__->meta->add_coercion({
	name               => 'Format',
	type_constraint    => DateTime,
	coercion_generator => sub {
		my $format = $_[2];
		$format = use_module("DateTime::Format::$format")->new
			unless ref($format);
		return (
			Str,
			sub { $format->parse_datetime($_) },
		);
	},
});

1;

__END__

=pod

=encoding utf-8

=for stopwords datetime

=head1 NAME

Types::DateTime - type constraints and coercions for datetime objects

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Types-DateTime>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2014 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

