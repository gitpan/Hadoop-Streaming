package Hadoop::Streaming;
BEGIN {
  $Hadoop::Streaming::VERSION = '0.102490';
}

#ABSTRACT: Contains Mapper, Combiner and Reducer roles to simplify writing Hadoop Streaming jobs 


1;

__END__
=pod

=head1 NAME

Hadoop::Streaming - Contains Mapper, Combiner and Reducer roles to simplify writing Hadoop Streaming jobs 

=head1 VERSION

version 0.102490

=head1 SYNOPSIS

    package My::Hadoop::Example;
    use Moose::Role;

    sub map 
    { 
        my ($line) = @_;
        ...
        emit( $key => $value);
    }
    sub reduce 
    { 
        my ( $key, $value_iterator) = @_;
        ...
        while( $value_iterator->has_next() ) { ... }
        emit( $key, $composite_value );
    } 
    sub combine 
    { 
        my ( $key, $value_iterator) = @_;
        ...
        while( $value_iterator->has_next() ) { ... }
        emit( $key, $composite_value );
    }

    package My::Hadoop::Example::Mapper;
    use Moose;
    with Hadoop::Streaming::Mapper,   My::Hadoop::Example;

    package My::Hadoop::Example::Combiner;
    use Moose;
    with Hadoop::Streaming::Combiner, My::Hadoop::Example;

    package My::Hadoop::Example::Reducer;
    use Moose;
    with Hadoop::Streaming::Reducer,  My::Hadoop::Example;

    1;

mapper executable:

  #!/usr/bin/perl
  use My::Hadoop::Example;
  My::Hadoop::Example::Mapper->run();

combiner executable:

  #!/usr/bin/perl
  use My::Hadoop::Example;
  My::Hadoop::Example::Combiner->run();

reducer executable:

  #!/usr/bin/perl
  use My::Hadoop::Example;
  My::Hadoop::Example::Reducer->run();

=head1 DESCRIPTION

Hadoop::Streaming::* provides a simple perl interface to the Streaming interface of Hadoop.

Hadoop is a system "reliable, scalable, distributed computing."  Hadoop was developed at Yahoo! and is now maintained by the Apache Software Foundation.  

Hadoop provides a distributed map/reduce framework.  Mappers take lines of unstructured file data and produce key/value pairs.  These key/value pairs are merged and sorted by key and provided to Reducers.  Reducers take key/value pairs and produce higher order data.   This works for data that where output key/value pairs can be determined from a single line of data in isolation.  The Reducer is provided sho

=over

=item Hadoop's Streaming Interface

The Streaming interface provides a simple API for writing Hadoop jobs in any language.  Jobs are provided input on STDIN and output is expected on STDOUT.  Key value pairs are separated by a TAB character. 

Streaming map jobs are provided an input of lines instead of key-value pairs.  See Hadoop::Streaming::Mapper INTERFACE DETAILS for an explanation.

Reduce jobs are provided a stream of key\tvalue lines.  multivalued keys appear on an input line once for each key\value.  The stream is guaranteed to be sorted by key.  The reduce job must track the key/value pairs and manually detect a key change.

=item Hadoop::Streaming::Mapper interface

Hadoop::Mapper consumes and chomps lines from STDIN and calls map($line) once per line.  This is initiated by the run() method.

example mapper input:
    line1
    line2
    line3

Hadoop::Mapper transforms this into 3 calls to map()
    map(line1)
    map(line2)
    map(line3)

=item Hadoop::Streaming::Reducer interface

Hadoop::Reducer abstracts this stream into an interface of (key, value-iterator).  reduce() is called once per key, instead of once per line.  The reduce job pulls values from the iterator and outputs key/value pairs to STDOUT.  emit() is provided as a convenience for outputing key/value pairs.

example reducer input:
    key1 value1
    key2 valuea
    key2 valuec
    key2 valueb
    key3 valuefoo
    key3 valuebar

Hadoop::Streaming::Reduce transforms this input into three calls to reduce():
    reduce( key,  iterator_over(qw(value1)) );
    reduce( key2, iterator_over(qw(valuea valuec valueb)) );
    reduce( key3, iterator_over(qw(valuefoo valuebarr)) );

=item Hadoop::Streaming::Combiner interface

The Hadoop::Streaming::Combiner interface is analagous to the Hadoop::Streaming::Reducer interface.  combine() is called instead of reduce() for each key.  The above example would produce three calls to combine():
    combine( key,  iterator_over(qw(value1)) );
    combine( key2, iterator_over(qw(valuea valuec valueb)) );
    combine( key3, iterator_over(qw(valuefoo valuebarr)) );

=back

=head1 SEE ALSO

=over 4

=item Map/Reduce at wikipedia

http://en.wikipedia.org/wiki/MapReduce

=item Hadoop

http://hadoop.apache.org

=item Hadoop Streaming interface: 

http://hadoop.apache.org/common/docs/r0.20.1/streaming.html

=item PAR::Packer

http://search.cpan.org/perldoc?PAR::Packer

=back

=head1 EXAMPLES

=over 4

=item run locally without hadoop

To test locally the examples from the SYNOPSIS() section, we must provide the sort function provided by hadoop.  For small test_input_file examples this can be done in one large pipe:

  my_mapper < test_input_file | sort | my_combiner | my_reducer

For larger files, make intermediary output files.  The output of the intermediate files can be verified and used to demonstrate the efficiency of the (optional) combiner.

  my_mapper < test_input_file > output.map        && \
  sort output.map > output.mapsort                && \
  my_combiner < output.mapsort > output.combine   && \
  my_reducer < output.combine > output.reduce 

=item hadoop commandline

Run this in hadoop from the shell:

  hadoop                                     \
      jar $streaming_jar_name                \
      -D mapred.job.name="my hadoop example" \
      -input    my_input_file                \
      -output   my_output_hdfs_path          \
      -mapper   my_mapper                    \
      -combiner my_combiner                  \
      -reducer  my_reducer

$streaming_jar_name is the full path to the streaming jar provided by the installed hadoop.  For my 0.20 install the path is:

The -D line is optional.  If included, -D lines must come directly after the jar name.

For this hadoop job to work, the mapper, combiner and reducer must be full paths that are valid on each box in the hadoop cluster.  There are a few ways to make this work.

=item hadoop job -files option

Additional files may be bundled into the hadoop jar via the '-files' option to hadoop jar.  These files will be included in the jar that is distributed to each host.  The files will be visible in the current directory of the process.  Subdirectories will not be created.

example:
  hadoop                                     \
      jar $streaming_jar_name                \
      -D mapred.job.name="my hadoop example" \
      -input    my_input_file                \
      -output   my_output_hdfs_path          \
      -mapper   my_mapper                    \
      -combiner my_combiner                  \
      -reducer  my_reducer                   \
      -file     /path/to/my_mapper           \
      -file     /path/to/my_combiner         \
      -file     /path/to/my_reducer

=item using perl modules

All perl modules must be installed on each hadoop cluster machine.  This proves to be a challenge for large installations.  I have a local::lib controlled perl directory that I push out to a fixed location on all of my hadoop boxes (/apps/perl5) that is kept up-to-date and included in my system image.  Previously I was producing stand-alone perl files with PAR::Packer (pp), which worked quite well except for the size of the jar with the -file option.  The standalone files can be put into hdfs and then included with the jar via the -cacheFile option.  An option I have not investigated is using -cacheJar to push a jar of my necessary perl files along with the job.

=over 4

=item local::lib 

* install all modules into a local::lib controlled directory, push this directory to all of the hadoop cluster boxes (rsync, app installer, nfs mount ), explicitly include this directory in a C<use lib> or C<use local::lib> line in your mapper/reducer/combiner files.

  #!/usr/bin/perl
  use strict; use warnings;
  use lib qw(/apps/perl5);
  use My::Example::Job;
  My::Example::Job::Mapper->run();

* The mapper/reducer/combiner files can be included with the job via -file options to hadoop jar or they can be referenced directly if they are in the shared environment.

=item full path of shared file

  hadoop                                     \
      jar $streaming_jar_name                \
      -input    my_input_file                \
      -output   my_output_hdfs_path          \
      -mapper   /apps/perl5/bin/my_mapper    \
      -combiner /apps/perl5/bin/my_combiner  \
      -reducer  /apps/perl5/bin/my_reducer

=item local path of included -file file

  hadoop                                     \
      jar $streaming_jar_name                \
      -input    my_input_file                \
      -output   my_output_hdfs_path          \
      -file     /apps/perl5/bin/my_mapper    \
      -file     /apps/perl5/bin/my_combiner  \
      -file     /apps/perl5/bin/my_reducer   \ 
      -mapper   ./my_mapper                  \
      -combiner ./my_combiner                \
      -reducer  ./my_reducer

=back

=item PAR::Packer / pp

Use pp (installed via PAR::Packer) to produce a perl file that needs only a perl interpreter to execute.  I use -x option to run the my_mapper script on blank input, as this forces all of the necessary modules to be loaded and thus tracked in my PAR file.

  mkdir packed
  pp my_mapper -B -P -Ilib -o packed/my_mapper -x my_mapper < /dev/null
  hadoop                                     \
      jar $streaming_jar_name                \
      -input    my_input_file                \
      -output   my_output_hdfs_path          \
      -file     packed/my_mapper             \
      -mapper   ./my_mapper

To simplify this process and reduce errors, I use make to produce the packed binaries.  Indented lines after "name :" lines are indented with a literal tab, as per Makefile requirements.

    #Makefile for PAR packed apps
    PERLTOPACK     =                              \
        region-dma-mapper.pl                      \
        region-dma-reducer.pl                     \
        multiattribute-mapper.pl                  \
        multiattribute-combiner.pl                \
        multiattribute-reducer.pl
    
    PERL_LIBRARIES =                              \
        lib/RegionDMA.pm                          \
        lib/RegionDMA/Lookup.pm                   \
        lib/Truthiness/Allocator.pm
    
    PACKEDTARGETS  = $(patsubst %,packed/%,$(PERLTOPACK))
    PACK           = packed $(PACKEDTARGETS)
    
    PACK : $(PACK) 
        echo "pack: $(PACKTARGETS)"
    packed:
        mkdir packed
    #
    # perl files to compile via pp
    #
    $(patsubst %,packed/%,$(PERLTOPACK)) : packed/%.pl : bin/%.pl $(PERL_LIBRARIES)
        time pp $< -B -P -I lib/ -o $@ -x $< < /dev/null
    ### END MAKEFILE

=back

=head1 AUTHORS

=over 4

=item *

andrew grangaard <spazm@cpan.org>

=item *

Naoya Ito <naoya@hatena.ne.jp>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Naoya Ito <naoya@hatena.ne.jp>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

