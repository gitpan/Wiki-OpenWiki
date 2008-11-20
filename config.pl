 
sub new {

    my ($self, $r) = @_ ;
my $dbname = '';
my $dbuser = '';
my $dbpass = '';
my $adminpass = '';
my $sitename = 'Test';

$self->{meta} = [
		{name=>'A' ,type => '1' },
		{name=>'B' ,type => '2' },
		{name=>'C' ,type => '3' },
		{name=>'D' ,type => '4' },
		];

$self->{dbh} = DBI->connect("dbi:mysql:${dbname}:localhost",$dbuser ,$dbpass ,{RaiseError => '1'});
my $store     = Wiki::Toolkit::Store::MySQL->new(
                        dbname => $dbname,
                        dbuser => $dbuser,
                        dbpass => $dbpass,
);
my $indexdb = Search::InvertedIndex::DB::Mysql->new(
                              -db_name    => $dbname ,
                              -username   => $dbuser,
                              -password   => $dbpass,
                              -table_name => 'siindex',
                              -lock_mode  => 'EX' );

  my $search    = Wiki::Toolkit::Search::SII->new(
      indexdb => $indexdb );
  my $formatter = Wiki::Toolkit::Formatter::UseMod->new(extended_links  => 0,
                 implicit_links  => 1,
                 allowed_tags    => [qw(b i br p a img hr h1 h2 h3 h4 h5 h6 font blockquote table u em strong)],  # defaults to none
                 macros          => {},
                 node_prefix     => 'wiki.cgi?node='
                );

  $self->{wiki}      = Wiki::Toolkit->new( store     => $store,
                                  search    => $search ,
                                  formatter => $formatter,
                                        );




  $self->{node_config} = {
				map {$_->{type}, $_->{name}  } @ { $self->{meta} } 
			}; 

  $self->{adminpassword} = $adminpass;
  $self->{sitename} = $sitename;
}	
1;
