#!/usr/bin/perl

use strict;
use warnings;
my %arg;
&parseCommandLine;

my $input_file = $arg{-input_file};
my @phone_list_contents;
&get_phone_list_contents;
my %individuals;
my @phonenumbers;
my $line_num = 0;

foreach my $content (@phone_list_contents)
{
	$line_num++;
	chomp $content;
	$content = uc($content);	
	my @line_contents = split(/\t/, $content);
	if (@line_contents != 2) {	
		die "Irregular input at line $line_num\n";
	}
	else {
		my $phone = $line_contents[1];
		$phone =~ s/[^a-zA-Z0-9]*//g; 
		my $name = $line_contents[0];
		# could also do this better with a complex data structure such as a hash of arrays
		if (!exists $individuals{$phone}) #phone number matches either all include the area code, or none include the area code. This could be a potential source of error. The data might be inherently intractable, in that you could have two matching phone numbers without area codes, but which actually are in two different area codes. Or you could have two numbers which should match, but one has an area code and the other doesn't. I don't have a programmatic way to distinguish these possibilities, unless we could assume that no two numbers will be the same unless they do in fact share an area code.  
		{
			$individuals{$phone} = $name;
		}
		else
		{
		$individuals{$phone}.=",".$name; 
		}
	}
}

open (OUTPUT, ">$input_file.phone_associations.from_perl_script.txt") or die "Cannot open output file $input_file.phone_associations.from_perl_script.txt\n";
while ( my ($key, $value) = each(%individuals) ) {
        print OUTPUT "$key\t$value\n"; #could also have kept the original hash around with the original format of the phone number to output, but I don't see an advantage. 
}
close OUTPUT;


sub get_phone_list_contents
{
	open (FILE, $input_file) or die "Can't open $input_file\n";
	@phone_list_contents = <FILE>;
	close FILE;
}


sub parseCommandLine {

    my ($useage) = "phone_number_associator.pl

	-input_file  The tab separated input file
			\n";


       $arg{-input_file} = "";

      for (my $i = 0; $i <= $#ARGV; $i++)
        {
                if ($ARGV[$i] =~ /^-/)
                {
                        $arg{$ARGV[$i]} = $ARGV[$i+1];
                }
        }
        die($useage) if (!($arg{-input_file}));
}
