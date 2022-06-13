#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use feature qw(say);
use Data::Dump qw(dump);

my $correct_answer_limit = shift @ARGV || 5;
my $max_int = shift @ARGV || 12;
my $operators = shift @ARGV || '';
$operators =~ s/[^+*\/-]//g;
$operators ||= '+-*';
my $ops = [split "", $operators];
say "Welcome to math-test!";
say "Settings: correct answer limit: $correct_answer_limit, Highest question number: $max_int, operators: " . dump $ops;
say "Press ctrl+d to exit";
my $question;
my $answer = raise_question();
my %score;
while (my $line = <>) {
    chomp $line;
    if ($line !~ /^[\d-]+$/) {
        warn "Invalid: $line";
        print $question;
        next;
    }
    if (int($line) eq $answer) {
        say "Correct";
        $score{Correct}++;
        last unless --$correct_answer_limit;
    } else {
        say "Wrong, the answer is: $answer";
        $score{Wrong}++;
    }
    $answer = raise_question();
}
say "\nScore: " . dump \%score;
say "Press up and enter to go again";

sub raise_question {
    my $a = int(rand($max_int)) + 1;
    my $b = int(rand($max_int)) + 1;
    my $op = $ops->[int(rand(scalar @$ops))];
    if ($op eq '-') {
        if ($a < $b) {
            my $tmp = $a;
            $a = $b;
            $b = $tmp;
        }
    }
    if ($op eq '/') {
        my $numerator = $a * $b;
        my $answer = $b;
        $question = "$a x ? = $numerator?\n$numerator / $a = ";
        print $question;
        return $answer;
    }
    $question = "$a $op $b = ";
    my $answer = eval "$a $op $b";
    print $question;
    return $answer;
}
