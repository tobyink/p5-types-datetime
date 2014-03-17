=pod

=encoding utf-8

=head1 PURPOSE

Test that Types::DateTime compiles.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2014 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use Test::Modern -requires => { 'DateTime::Format::ISO8601' => '0.06' };
use Types::DateTime -all;

my $type = DateTime->plus_fallback_coercions(Format['ISO8601']);

is_deeply(
	$type->coerce(['x', 'y', 'z']),
	['x', 'y', 'z'],
	'cannot coerce from arrayref',
);

object_ok(
	sub { $type->coerce('now') },
	'$dt coerced from "now"',
	isa  => 'DateTime',
	more => sub {
		my $self = shift;
		my $diff = 'DateTime'->now() - $self;
		cmp_ok($diff->in_units('seconds'), '<', 30, 'looks recent');
	},
);

object_ok(
	sub { $type->coerce('2001-02-03T04:05:06+08:00') },
	'$dt coerced from ISO 8601 datetime with zone',
	isa  => 'DateTime',
	more => sub {
		my $self = shift;
		is($self->year, 2001, 'year');
		is($self->month, 2, 'month');
		is($self->day, 3, 'day');
		is($self->hour, 4, 'hour');
		is($self->minute, 5, 'minute');
		is($self->second, 6, 'second');
		object_ok(
			$self->time_zone,
			'$time_zone',
			isa  => 'DateTime::TimeZone',
			more => sub {
				my $time_zone = shift;
				is($time_zone->name, '+0800', 'name');
				is($time_zone->offset_for_datetime($self), 8*3600, 'offset_for_datetime');
			},
		);
	},
);

my $utc_type = DateTimeUTC->plus_fallback_coercions(Format['ISO8601']);

object_ok(
	sub { $utc_type->coerce('2001-02-03T04:05:06+08:00') },
	'$dt coerced to UTC from ISO 8601 datetime with zone',
	isa  => 'DateTime',
	more => sub {
		my $self = shift;
		is($self->year, 2001, 'year');
		is($self->month, 2, 'month');
		is($self->day, 2, 'day');
		is($self->hour, 20, 'hour');
		is($self->minute, 5, 'minute');
		is($self->second, 6, 'second');
		object_ok(
			$self->time_zone,
			'$time_zone',
			isa  => 'DateTime::TimeZone',
			more => sub {
				my $time_zone = shift;
				is($time_zone->name, 'UTC', 'name');
				is($time_zone->offset_for_datetime($self), 0, 'offset_for_datetime');
			},
		);
	},
);

done_testing;
