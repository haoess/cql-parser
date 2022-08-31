use strict;
use warnings;
use Test::More qw( no_plan );
use Test::Exception;

use_ok( 'CQL::Parser' );
my $parser = CQL::Parser->new();

my $node = $parser->parse( "origami" );
is( $node->toManticore(), 'origami', 'simple word search' );

$node = $parser->parse( "lexic*" );
is( $node->toManticore(), "lexic*", "right hand truncation" );

$node = $parser->parse( q["library of congress"] );
is( $node->toManticore(), q["library of congress"], "phrase search" );

$node = $parser->parse( q[librarians and "information scientists"] );
is( $node->toManticore(), q[librarians & "information scientists"], 'boolean intersection' );

$node = $parser->parse( q[origami or "paper folding"] );
is( $node->toManticore(), q[origami | "paper folding"], 'boolean union' );

$node = $parser->parse( q[Thanksgiving not Christmas] );
is( $node->toManticore(), q[Thanksgiving !Christmas], 'boolean negation' );

$node = $parser->parse( q[dc.creator="Thomas Jefferson"] );
is( $node->toManticore(), q[@dc.creator "Thomas Jefferson"], 'field searching' );

$node = $parser->parse( q[("paper folding" or origami) and japanese] );
is( $node->toManticore(), q[("paper folding" | origami) & japanese], 'nesting with parens' );

$node = $parser->parse( q[author = /fuzzy tailor] );
is( $node->toManticore(), q[@author tailor~], 'relation modifier of fuzzy search' );

$node = $parser->parse( q[complete prox dinosaur] );
is( $node->toManticore(), q["complete dinosaur"~1], "proximity search" );

$node = $parser->parse( q[ribs prox/distance>=5/unit=paragraph chevrons] );
is( $node->toManticore(), q["ribs chevrons"~5], "proximity search, ignore unsupported parameters" );

$node = $parser->parse( q[title exact fish] );
is( $node->toManticore(), q[@title ^fish$ & @title =fish], "exact modifier" );

$node = $parser->parse( q[title==fish] );
is( $node->toManticore(), q[@title ^fish$ & @title =fish], "exact modifier" );

$node = $parser->parse( q[title=fish] );
is( $node->toManticore(), q[@title fish], "eq modifier (partial match)" );

$node = $parser->parse( q[title<>fish] );
is( $node->toManticore(), q[@title !fish], "not operator" );

$node = $parser->parse( q[title adj "big fish"] );
is( $node->toManticore(), q[@title "big fish"], "phrase search" );

$node = $parser->parse( q[title all "big fish"] );
is( $node->toManticore(), q[@title big & @title fish], "multiple terms via AND" );

$node = $parser->parse( q[title all "big \"fish\""] );
is( $node->toManticore(), q[@title big & @title "fish"], "multiple terms via AND" );

$node = $parser->parse( q[title any "big fish"] );
is( $node->toManticore(), q[@title big | @title fish], "multiple terms via OR" );

$node = $parser->parse( q[title any "big \"fish\""] );
is( $node->toManticore(), q[@title big | @title "fish"], "multiple terms via OR" );

#$node = $parser->parse( q[cql.allRecords = 1 NOT title = fish] );
#is( $node->toManticore(), q[* & @title !fish], "multiple terms via OR" );
