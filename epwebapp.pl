use strict;
use Wiki::Toolkit;
use Wiki::Toolkit::Store::MySQL;
use Search::InvertedIndex::DB::DB_File_SplitHash;
use Wiki::Toolkit::Search::SII;
use Wiki::Toolkit::Formatter::UseMod;
use Wiki::Toolkit::Formatter::Default;
use Data::Dumper;
use DateTime;
#use Embperl;


sub init 
    {
    my $self     = shift ;
    my $r        = shift ;

    my $config = Execute ({object => 'config.pl', syntax => 'Perl'}) ;

    $config -> new ($r) ;    
    
    $r -> {config} = $config  ;    

	my $action = $fdat{action}||'display';
	my $node   = $fdat{node}||'HomePage';
	
	my $path = $ENV{PATH_INFO};
	my $template = 'temp1';
	if ( $path ) {
        	my @path = split(/\//,$path);
	        $node = $path[2]||'HomePage';
        	$action = $path[1]||'display';
		$template = $path[3]||'temp1';
	}

	
	$r->{node} = $node;
	$r->{action} = $action;
	$r->{template} = $r->{action} eq 'edit' ? 'tempedit':$template; #Edit do not need all headers

	$r->{checksum} = $fdat{checksum};
	$r->{version} = $fdat{version};


	$r->{node_exists} = $r->{config}->{wiki}->node_exists(
                               name        => $r->{node},
                               ignore_case => 1,
                             );
        #if node does not exists dislay the edit page else the display page. Also retrive the node

        if ($r->{node_exists}) {
                $r->{node_details} = $r->{version} ne 0? {$r->{config}->{wiki}->retrieve_node(name=> "$r->{node}",version=>$r->{version} ) } : {$r->{config}->{wiki}->retrieve_node(name=> "$r->{node}", ) };
                $r->{cooked} = $r->{config}->{wiki}->format($r->{node_details}->{content});
                $r->{checksum}||=$r->{node_details}->{checksum};
                $r->{version}||=$r->{node_details}->{version};
        }


	if ($r->{action} eq 'commit' ) {
		my $submitted_content = $fdat{"content"};
	        $submitted_content =~ s/\'/&#39;/sg;
        	$submitted_content =~ s/[\r\n]+//g;
	        if ($r->{node_details}->{metadata}->{editable}[0] ne 'admin' && !$udat{'~logged_in'} ) {
      
#		my $cksum = $r->{node_details}->{checksum} eq $r->{"checksum"}?$node_hash{checksum}:undef;
	        $r->{written} = $r->{config}->{wiki}->write_node($r->{node}, $submitted_content, $r->{checksum},{name=>$fdat{name}||$ENV{'REMOTE_ADDR'},
                                                                         email=>$fdat{'email'}||'',
                                                                         phone=>$fdat{'phone'}||'',
                                                                         editable=>$fdat{editable}||'',
                                                                         dated=>DateTime->now()->ymd()||'',
                                                                         category=>$fdat{category}||'',
                                                                        });
		}
	} elsif ($r->{action} eq 'search') {
	       $r->{results_search} = {$r->{config}->{wiki}->search_nodes($node)};
	} elsif ($r->{action} eq 'admin2') {
		if($fdat{'password'} eq $r->{config}->{adminpassword}){
	                $udat{'~logged_in'} = '1' ;
        	}else{
                	$udat{'~logged_in'} = '0';
	        }

	} elsif ($r->{action} eq 'delete') {
		if($udat{'~logged_in'} == 1) {
	                my $version = $fdat{'version'} ne 'all'?$fdat{'version'}:0;
        	        $r->{config}->{wiki}->delete_node(name=>$r->{node},version=>$version);
		}

	} elsif ($r->{action} eq 'display') {
		$r->{versions} = [];
		$r->{versions} = [$r->{config}->{wiki}->list_node_all_versions($r->{node}) ] ;
	} elsif ($r->{action} eq 'alllinks') {
		@{$r->{allnodes}} = $r->{config}->{wiki}->list_all_nodes;
	}





	#Announcement section - currently fetches each time from DB - Later put into session and fetches only for the first time else from DB

	my $sth = $r->{config}->{dbh}->prepare(qq{select a_id,a_announcement,DATE_FORMAT(a_dated, '%d-%m-%y') from announcements where a_from<=now() and a_till>=now() order by a_dated DESC});
        $sth->execute();
        while(my $row_a = $sth->fetchrow_arrayref){
		push (@{$r->{announcements}},[$row_a->[1],$row_a->[2]]);
        }
  
}


sub edit {
	my $self=shift;
	my $r= shift;
	$escmode=0;

        print OUT <<EOF;

        <h1>Editing $r->{node}  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;- &nbsp; &nbsp; &nbsp; &nbsp &nbsp;$r->{config}->{sitename}</h1>
        <form name="myform" method="POST" action="$ENV{SCRIPT_NAME}/commit/$r->{node}" onsubmit="return submitForm();" >


<script language="JavaScript" type="text/javascript">
<!--
function submitForm() {
//make sure hidden and iframe values are in sync before submitting form
updateRTE('content'); //use this when syncing only 1 rich text editor ("rtel" is name of editor)
//updateRTEs(); //uncomment and call this line instead if there are multiple rich text editors inside the form
//alert("Submitted value: "+document.myform.content.value) //alert submitted value
return true; //Set to false to disable form submission, for easy debugging.
}

//Usage: initRTE(imagesPath, includesPath, cssFile)
initRTE("/rte/images/", "/rte/", "/rte/");
//-->
</script>


<script language="JavaScript" type="text/javascript">
<!--



//Usage: writeRichText(fieldname, html, width, height, buttons, readOnly)
writeRichText('content', '$r->{node_details}->{content}', 400, 200, true, false);
//-->
</script>




<p>
Optional Stuff - Will not be displayed on to the webpage(Except name).
<hr>
<pre>
Name : <input type="text" name="name" value="">

Email : <input type="text" name="email" value="">


Phone / Mobile No: <input type="text" name="phone" value="">

Editable : <select name="editable">
                <option value="all">All users can edit this page</option>
                <option value="admin">Only Administrator can edit this page</option>
                </select>
EOF

	

	my $category = $r->{node_details}->{metadata}->{category}[0];


print OUT qq~
Category: <select name="category">
~;
	 foreach my $meta (@ { $r->{config}->{meta} } ) { 
	       print OUT qq~<option value='$meta->{type}'~ ;
		print OUT 'selected' if $meta->{type} eq $category ;
		print OUT qq~>$meta->{name}</option>~;
	}

print OUT qq~                </select>

</pre>



  <p>
        <input type="hidden" name="checksum" value="$r->{checksum}">
        <input type="hidden" name="node" value="$r->{node}">
  <input type="submit" value="commit" name="action">
<!--  <input type="submit" value="preview" name="action"> -->
  <input type="reset" value="Reset" name="B2"></p>
</form>

~;
	

}

sub admin {      
        
	$escmode=0;
	print OUT <<EOF;
                <h3>Enter Admin password to continue</h3>
                <form action="$ENV{SCRIPT_NAME}/admin2" method="POST">
                <input type="password" name="password" value="">

        </form>
EOF

  } 
sub display {
	my $self = shift;
	my $r = shift;
	$escmode=0;
	if( !$r->{node_exists} ) {
                $http_headers_out{'location'} = $ENV{SCRIPT_NAME}.'/edit/'.$r->{node} ;
        }
	print OUT $r->{cooked};
	print OUT "<h6>Last edited by $r->{node_details}->{metadata}->{name}[0] on  $r->{node_details}->{metadata}->{dated}[0]</h6>";
}

sub commit{	
	my $self = shift;
        my $r = shift;
	if( $r->{written} ) {
		$http_headers_out{'location'} = $ENV{SCRIPT_NAME}.'/display/'.$r->{node} ;	
	} else {
		$http_headers_out{'location'} = $ENV{SCRIPT_NAME}.'/display/error' ;
	}
}

sub admin2 {
        my $self = shift;
        my $r = shift;
 	if ($udat{'~logged_in'} == 1) { #verified in it
		$http_headers_out{'location'} = $ENV{SCRIPT_NAME}.'/display/logged_in' ;
	}else{
		$http_headers_out{'location'} = $ENV{SCRIPT_NAME}.'/display/error' ;
	}

}

sub alllinks {
	my $self = shift;
        my $r = shift;
        $escmode=0;
        foreach (sort @{$r->{allnodes}}) {
                print OUT qq~<a href="$ENV{SCRIPT_NAME}/display/$_">$_</a><br>~;
        }
}


sub search {
        my $self = shift;
        my $r = shift;
	$escmode=0;
	foreach (keys %{$r->{results_search}}) {
	 	print OUT qq~<a href="$ENV{SCRIPT_NAME}/display/$_">$_</a><br>~;
	}
}
