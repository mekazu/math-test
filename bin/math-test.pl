#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

use feature qw(say);
use Data::Dump qw(dump);

my $correct_answer_limit = shift @ARGV || 5;
my $min_int = shift @ARGV || 2;
my $max_int = shift @ARGV || 12;
my $operators = shift @ARGV || '';
my $batch_mode = $ENV{'BATCH'};
$operators =~ s/[^+*\/-]//g;
$operators ||= '+-*';
my $ops = [split "", $operators];
my @question_range = ($min_int..$max_int);
say "Welcome to math-test!";
say "Settings: correct answer limit: $correct_answer_limit, question numbers: @{[dump \@question_range]}, operators: " . dump $ops;
say "Press ctrl+d to exit";
my $question;
my @summary;
my $answer = raise_question();
my %score;
while (my $input = <>) {
    chomp $input;
    if ($input !~ /^[\d-]+$/) {
        warn "Invalid: $input";
        print $question;
        next;
    }
    my $correct = int($input) eq $answer;
    my $result;
    if ($correct) {
        $result = "Correct";
        $score{Correct}++;
    } else {
        $result = "Wrong, the answer is: $answer";
        $score{Wrong}++;
    }
    push @summary, "$question$input ... $result";
    say $result unless $batch_mode;
    last if $correct and not --$correct_answer_limit;
    $answer = raise_question();
}
say "\nResults:\n" . join "\n", @summary if $batch_mode;
say "\nScore: " . dump \%score;
say "Press up and enter to go again";

sub raise_question {
    my $op = $ops->[int(rand(scalar @$ops))];
    my $a = next_in_question_range();
    my $b = next_in_question_range();
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
        say "$a x ? = $numerator?";
        $question = "$numerator / $a = ";
        print $question;
        return $answer;
    }
    $question = "$a $op $b = ";
    my $answer = eval "$a $op $b";
    print $question;
    return $answer;
}

sub next_in_question_range {
    @question_range = ($min_int..$max_int) unless @question_range;
    my $range_length = scalar @question_range;
    my $index = random_int_in_range(0, $range_length - 1);
    warn "Range length: $range_length, index: $index, question range: " . dump \@question_range if $ENV{'DEBUG'};
    my $next = splice(@question_range, $index, 1);
    return $next;
}

sub random_int_in_range {
    my ($min, $max) = @_;
    return int(rand($max - $min + 1)) + $min;
}
