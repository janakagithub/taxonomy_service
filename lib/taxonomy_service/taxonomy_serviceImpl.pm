package taxonomy_service::taxonomy_serviceImpl;
use strict;
use Bio::KBase::Exceptions;
# Use Semantic Versioning (2.0.0-rc.1)
# http://semver.org
our $VERSION = '0.0.1';
our $GIT_URL = 'https://github.com/janakagithub/taxonomy_service.git';
our $GIT_COMMIT_HASH = 'de7b39fc05a7c58d32e5fed3c9d6e2a9572df4b3';

=head1 NAME

taxonomy_service

=head1 DESCRIPTION

A KBase module: taxonomy_service
This module serve as the taxonomy service in KBase.

=cut

#BEGIN_HEADER
use Bio::KBase::AuthToken;
use Bio::KBase::workspace::Client;
use Config::IniFiles;
use Data::Dumper;
use POSIX;
use FindBin qw($Bin);
use JSON;
use LWP::UserAgent;
use Try::Tiny;
use XML::Simple;
use Cache::MemoryCache;




sub search_solr
{
    my ($taxonomy_core, $solrurl, $search, $start, $limit, $method) = @_;
    my $url = $solrurl."/$taxonomy_core/select?q=*.*&fq=$search*&sort=scientific_name+asc&start=$start&rows=$limit&fl=scientific_name%2Cparent_taxon_ref%2Cws_ref&df=scientific_name&wt=json&indent=true";
   #my $url = $solrurl."/$taxonomy_core/select?q=*%3A*&fq=$search*&start=$start&rows=$limit&fl=scientific_name%2Cparent_taxon_ref%2Cws_ref&wt=json&indent=true";
	my $method = 'GET';
	my $jsonf = solr_request ($method, $url);
	return $jsonf;
}

sub get_genomes
{                                                       #&start=$start&rows=$limit
    my ($taxonomy_core, $solrurl, $search, $start, $limit, $method) = @_;
    my $url = $solrurl."/$taxonomy_core/select?q=*$search*&start=$start&rows=$limit&fl=scientific_name%2Cparent_taxon_ref%2Cws_ref%2Cscientific_lineage%2Cdomain%2Ckingdom%2Caliases%2Cdeleted&df=scientific_lineage&wt=json&indent=true";
    my $method = 'GET';
    my $jsonf = solr_request ($method, $url);
    return $jsonf;
}

sub get_taxa_by_ref
{
    my ($taxonomy_core, $solrurl, $search, $start, $limit, $df, $method) = @_;
    my $url = $solrurl."/$taxonomy_core/select?q=*$search*&fl=scientific_name%2Cparent_taxon_ref%2Cws_ref%2Cscientific_lineage%2Caliases%2Cdeleted&df=$df&wt=json&indent=true";
    my $method = 'GET';
    my $jsonf = solr_request ($method, $url);
    return $jsonf;
}


sub get_node_info
{
    my ($taxonomy_core, $solrurl, $search, $start, $limit, $df, $method) = @_;
    my $url = $solrurl."/$taxonomy_core/select?q=$search&fl=scientific_name%2Cparent_taxon_ref%2Cws_ref%2Cdomain%2Cscientific_lineage%2Caliases%2Cdeleted&df=$df&wt=json&indent=true";
    my $method = 'GET';
    my $jsonf = solr_request ($method, $url);
    return $jsonf;
}

sub format_taxa_name
{
    my ($search_word) = @_;
    $search_word =~ s/^\s+//;
    $search_word =~ s/\s+$//;
    $search_word =~ s/ /\\ /g;
    $search_word =~ s/\(/\\\(/g;
    $search_word =~ s/\)/\\\)/g;
    $search_word =~ s/\[/\\\[/g;
    $search_word =~ s/\]/\\\]/g;
    return $search_word;
}

sub solr_request
{

	my ($method, $url) = @_;
	# create a HTTP request
	try {
        my $ua = LWP::UserAgent->new();
    	my $request = HTTP::Request->new();
    	$request->method($method);
    	$request->uri($url);

    	my $response = $ua->request($request);
    	my $sn = $response->content();
    	my $code = $response->code();
        my $jsonf = JSON::from_json($sn);

        return $jsonf;
    }catch {
    # Print out the exception that occurred
    warn "SOLR request return code 403, caught error: $_";
    die;
    }

}

sub get_parent
{
    my ($solrurl, $taxonomy_core, $ref, $method, $def) = @_;
    my $url = $solrurl."/$taxonomy_core/select?q=*%3A*&fq=$ref&fl=scientific_name%2Cparent_taxon_ref%2Cws_ref&df=$def&wt=json&indent=true";
    my $jsonf = solr_request ($method, $url);
    return $jsonf;
}

sub search_parents
{
	my ($public_search, $taxonomy_core, $solrurl, $search_word, $method, $category) = @_;
	my $hits_list = [];

    if (@{$public_search}){
        for (my $i=0; $i< @{$public_search}; $i++){
            my $sci_name = $public_search->[$i]->{scientific_name};
            my $parent_ref = $public_search->[$i]->{parent_taxon_ref};
            if (defined $public_search->[$i]->{parent_taxon_ref}){
                my $def = "ws_ref";
                my$jsonf = get_parent ($solrurl, $taxonomy_core, $public_search->[$i]->{parent_taxon_ref}, $method, $def);
                #print &Dumper ($jsonf);
                #die;
                if ($jsonf->{responseHeader}->{params}->{fq} eq $public_search->[$i]->{parent_taxon_ref}){
                    my $each_taxon = {
                    label => $public_search->[$i]->{scientific_name},
                    id => $public_search->[$i]->{ws_ref},
                    parent => $jsonf->{response}->{docs}->[0]->{scientific_name},
                    parent_ref => $public_search->[$i]->{parent_taxon_ref},
                    category => $category
                    };
                    push ($hits_list, $each_taxon);
                }
            }
            else{
                my $each_taxon = {
                label => $public_search->[$i]->{scientific_name},
                id => $public_search->[$i]->{ws_ref},
                parent => "Unknown",
                parent_ref => "Unknown",
                category => $category
                };
                push ($hits_list, $each_taxon);
            }
        }
    }
    else{
        #my $s1 =~ s/str.//g, $search_word
        my @ps = split /\s+/, $search_word;
        my $psaL = @ps;
        for (my $i=0; $i< $psaL-1; $i++){
            pop (@ps);
            my $partial_string = join ("\\ ", @ps);
            #print "@ps\t *$partial_string*\n";
            my $def = "scientific_name";
            my $jsonf = get_parent ($solrurl, $taxonomy_core, $partial_string, $method, $def);
            if ($jsonf->{response}->{numFound} > 0){
                my $each_taxon = {
                    label => $search_word,
                    id => "new",  # this is the reference for new search word e.g K. oxytoca janaka
                    parent => $jsonf->{response}->{docs}->[0]->{scientific_name},
                    parent_ref => $jsonf->{response}->{docs}->[0]->{ws_ref},
                    category => $category
                };
                push ($hits_list, $each_taxon);
                last;
            }
            elsif( ($jsonf->{response}->{numFound} < 1 ) && ($search_word =~ /str/) ){
                $partial_string =~ s/substr.\\ //g;
                $partial_string =~ s/str.\\ //g;
                #print "modified partial string\t *$partial_string*\n";
                my $jsonf = get_parent ($solrurl, $taxonomy_core, $partial_string, $method, $def);

                if ($jsonf->{response}->{numFound} > 0){
                my $each_taxon = {
                    label => $search_word,
                    id => "new",  # this is the reference for new search word e.g K. oxytoca janaka
                    parent => $jsonf->{response}->{docs}->[0]->{scientific_name},
                    parent_ref => $jsonf->{response}->{docs}->[0]->{ws_ref},
                    category => $category
                    };

                push ($hits_list, $each_taxon);
                last;
                }
            }
            else{
                next;
            }
        }
    }


    if (!@{$hits_list}){
        my $each_taxon = {
            label => $search_word,
            id => "new",  # this is the reference for new search word e.g K. oxytoca janaka
            parent => "Unknown",
            parent_ref => "Unknown",
            category => $category
            };

    push ($hits_list, $each_taxon);
    }
    #print &Dumper ($hits_list);
	return $hits_list;
}

sub search_private
{
    my ($search, $wsClient,$taxonomy_core, $solrurl, $method, $private, $start, $limit ) = @_;
    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
	my $token=$ctx->token;
	my $provenance=$ctx->provenance;
	my $hits_list = [];
    my $usrws = $ctx->{user_id}.":private_taxonomy";
    my $search_word = lc($search);

    my $ws_params = {
        workspaces=> [$usrws],
        type => 'KBaseGenomeAnnotations.Taxon'
        };


    #Caching ws-list
    my $cache = Cache::MemoryCache->new( { 'namespace' => 'temp',
                                        'default_expires_in' => 30 } );

    my $obj_info_list = $cache->get('temp');
    if ( !defined $obj_info_list ){
        $cache->clear();
        $obj_info_list = $wsClient->list_objects($ws_params);
        $cache->set( 'temp', $obj_info_list );
    }


    my $psearch = [];
    for(my $i=0; $i< @{$obj_info_list}; $i++){
        my $info_ref = $obj_info_list->[$i];
        my $ob_ref =  $info_ref->[6]."/".$info_ref->[0]."/".$info_ref->[4];
        my $taxon=$wsClient->get_objects([{ref=>$ob_ref}])->[0]{data};
        #print "$taxon->{scientific_name}\n";
        my $sci_name = lc ($taxon->{scientific_name});
        if ($sci_name =~ /$search_word/){
            my $private_search = {
                scientific_name => $taxon->{scientific_name},
                parent_taxon_ref => $taxon->{parent_taxon_ref},
                ws_ref => $ob_ref
            };
            push ($psearch, $private_search);
        }
    }
    #print &Dumper ($psearch);
    $psearch->[$start..$limit];
    my $jsonf = search_parents($psearch, $taxonomy_core, $solrurl, $search_word, $method, $private);
	return $jsonf;
}

sub search_local
{
    my ($search, $wsClient,$taxonomy_core, $solrurl, $method, $ws, $local, $start, $limit ) = @_;
    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $hits_list = [];
    my $search_word = lc ($search);

    my $ws_params = {
        workspaces=> [$ws],
        type => 'KBaseGenomes.Genome'
        };

    #Caching ws-list
    my $cache = Cache::MemoryCache->new( { 'namespace' => 'temp',
                                        'default_expires_in' => 30 } );
    my $obj_info_list = $cache->get('temp');
    if ( !defined $obj_info_list ){
        $cache->clear();
        $obj_info_list = $wsClient->list_objects($ws_params);
        $cache->set( 'temp', $obj_info_list );
    }




    my $psearch = [];

    #print &Dumper ($obj_info_list);
    for(my $i=0; $i< @{$obj_info_list}; $i++){
        my $info_ref = $obj_info_list->[$i];
        my $ob_ref =  $info_ref->[6]."/".$info_ref->[0]."/".$info_ref->[4];
        my $genome_taxon=$wsClient->get_objects([{ref=>$ob_ref}])->[0]{data};
        if (defined $genome_taxon->{taxon_ref}){
            my $taxon=$wsClient->get_objects([{ref=>$genome_taxon->{taxon_ref}}])->[0]{data};
            #print "$taxon->{scientific_name}\n";
            my $sci_name = lc ($taxon->{scientific_name});
            if ($sci_name =~ /$search_word/){
                my $private_search = {
                    scientific_name => $taxon->{scientific_name},
                    parent_taxon_ref => $taxon->{parent_taxon_ref},
                    ws_ref => $genome_taxon->{taxon_ref}
                };
                push ($psearch, $private_search);
            }
        }
        else{
            print "Taxon reference could not be found for the genome $genome_taxon->{scientific_name}, user might want to assign a taxon\n";
            next;
        }
    }
    #print &Dumper ($psearch);
    $psearch->[$start..$limit];
    my $jsonf = search_parents($psearch, $taxonomy_core, $solrurl, $search_word, $method, $local);
    return $jsonf;
}
#END_HEADER

sub new
{
    my($class, @args) = @_;
    my $self = {
    };
    bless $self, $class;
    #BEGIN_CONSTRUCTOR

    my $config_file = $ENV{ KB_DEPLOYMENT_CONFIG };
    my $cfg = Config::IniFiles->new(-file=>$config_file);
    my $wsInstance = $cfg->val('taxonomy_service','workspace-url');
    die "no workspace-url defined" unless $wsInstance;

    $self->{'workspace-url'} = $wsInstance;

    #SOLR specific parameters
    if (! $self->{_SOLR_URL}) {
        $self->{_SOLR_URL} = "http://kbase.us/internal/solr-ci/search";
    }
    $self->{_SOLR_POST_URL} = $self->{_SOLR_URL};
    $self->{_SOLR_PING_URL} = "$self->{_SOLR_URL}/select";
    $self->{_AUTOCOMMIT} = 0;
    $self->{_CT_XML} = { Content_Type => 'text/xml; charset=utf-8' };
	$self->{_CT_JSON} = { Content_Type => 'text/json'};

    #END_CONSTRUCTOR

    if ($self->can('_init_instance'))
    {
	$self->_init_instance();
    }
    return $self;
}

=head1 METHODS



=head2 search_taxonomy

  $output = $obj->search_taxonomy($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.DropDownItemInputParams
$output is a taxonomy_service.DropDownData
DropDownItemInputParams is a reference to a hash where the following keys are defined:
	private has a value which is an int
	public has a value which is an int
	local has a value which is an int
	search has a value which is a string
	limit has a value which is an int
	start has a value which is an int
	workspace has a value which is a string
DropDownData is a reference to a hash where the following keys are defined:
	num_of_hits has a value which is an int
	hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem
DropDownItem is a reference to a hash where the following keys are defined:
	label has a value which is a string
	id has a value which is a string
	category has a value which is a string
	parent has a value which is a string
	parent_ref has a value which is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.DropDownItemInputParams
$output is a taxonomy_service.DropDownData
DropDownItemInputParams is a reference to a hash where the following keys are defined:
	private has a value which is an int
	public has a value which is an int
	local has a value which is an int
	search has a value which is a string
	limit has a value which is an int
	start has a value which is an int
	workspace has a value which is a string
DropDownData is a reference to a hash where the following keys are defined:
	num_of_hits has a value which is an int
	hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem
DropDownItem is a reference to a hash where the following keys are defined:
	label has a value which is a string
	id has a value which is a string
	category has a value which is a string
	parent has a value which is a string
	parent_ref has a value which is a string


=end text



=item Description



=back

=cut

sub search_taxonomy
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to search_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'search_taxonomy');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN search_taxonomy

    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);

    #my $start_time = [Time::HiRes::gettimeofday()];
    my $start = Time::HiRes::gettimeofday();
=head
#########################Begin of temp code where search is based on list of taxons in a file instead of SOLR###########################
    open INFILE, "/kb/module/data/orglist.txt" or die "Couldn't open html file $!\n";

    my %sHash;
    while (defined(my $input = <INFILE>)){
        chomp $input;
        #print "*$input*\n";
        $sHash{$input} = 1;
    }

    #for (grep /\b\Q$some_word\E\b/, keys %sHash)
    my @searchHits;
    my $count =0;
    for (grep /$params->{search}/, keys %sHash){
     	my $orgArr = {
        	label => $_,
        	id => "somews",
        	category => "some category"
       	};
     	push (@searchHits, $orgArr);
     	if ($count >= $params->{limit}){
     		last;
     	}
     	$count++;
	}

	my $arLen = @searchHits;
    #print "$arLen\n";
=cut
##############################################End of temp code for search ############################

########################################Search based on SOLR###################################################
	my $taxonomy_core = "taxonomy_ci";
	my $solrurl = $self->{_SOLR_URL};
	my $method = 'GET';
    my $hits_list = [];
    my $search_response->{response}->{numFound} = 0;
    my $private_list;
    my $category = "public";

    if ($params->{public} != 0){
        $search_response = search_solr($taxonomy_core, $self->{_SOLR_URL}, $params->{search}, $params->{start}, $params->{limit}, $method);
        $search_response->{response}->{docs}->[$params->{start}..$params->{limit}];
        $hits_list = search_parents ($search_response->{response}->{docs}, $taxonomy_core, $self->{_SOLR_URL},$params->{search}, $method, $category);


    }

    if ($params->{private} != 0){ #for debug purposes
        $category = "private";
        $private_list = search_private ($params->{search}, $wsClient,$taxonomy_core, $self->{_SOLR_URL}, $method, $category, $params->{start}, $params->{limit} );
        push @$hits_list, $_ foreach @$private_list;
        $search_response->{response}->{numFound} += @{$private_list};

    }

    if ($params->{local} != 0){ # for debug purposes
        $category = "local";
        my $local_list = search_local ($params->{search}, $wsClient,$taxonomy_core, $self->{_SOLR_URL}, $method, $params->{workspace}, $category, $params->{start}, $params->{limit});
    }

	$output = {
	    	hits => $hits_list,
	    	num_of_hits =>  $search_response->{response}->{numFound}
	};

    #my $diff = Time::HiRes::tv_interval($start_time);
    my $end = Time::HiRes::gettimeofday();
    #print "\n\n$diff\n";
    printf("%.2f\n", $end - $start);
    print &Dumper ($output);

    #END search_taxonomy
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to search_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'search_taxonomy');
    }
    return($output);
}




=head2 create_taxonomy

  $output = $obj->create_taxonomy($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.CreateTaxonomyInputParams
$output is a taxonomy_service.CreateTaxonomyOut
CreateTaxonomyInputParams is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	rank has a value which is a string
	comments has a value which is a string
	genetic_code has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	workspace has a value which is a string
CreateTaxonomyOut is a reference to a hash where the following keys are defined:
	ref has a value which is a taxonomy_service.ObjectReference
	scientific_name has a value which is a string
ObjectReference is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.CreateTaxonomyInputParams
$output is a taxonomy_service.CreateTaxonomyOut
CreateTaxonomyInputParams is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	taxonomic_id has a value which is an int
	kingdom has a value which is a string
	domain has a value which is a string
	rank has a value which is a string
	comments has a value which is a string
	genetic_code has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	workspace has a value which is a string
CreateTaxonomyOut is a reference to a hash where the following keys are defined:
	ref has a value which is a taxonomy_service.ObjectReference
	scientific_name has a value which is a string
ObjectReference is a string


=end text



=item Description



=back

=cut

sub create_taxonomy
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to create_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'create_taxonomy');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN create_taxonomy
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);

    #narrative input widget params - hardcoded for now
    $params->{genetic_code} = 11;
    $params->{parent} = "1779/87821/1";

    my $taxonomy_core = "taxonomy_ci";
    my $solrurl = $self->{_SOLR_URL};
    my $method = 'GET';
    my $private_search =1;
    my $private_list;


    #checking for private taxonomy ws
    my $private_tax_ws_ref;
    my $ws_list = $wsClient->list_workspaces ({excludeGlobal=> 1});
    my $ws_hash;
    for (my $i=0; $i< @{$ws_list}; $i++){
    	my @tempName = split /:/, $ws_list->[$i]->[0];
    	$ws_hash->{$ws_list->[$i]->[0]} = $ws_list->[$i];
    }

	#print &Dumper ($ws_hash);
	my $new_ws = $ctx->{user_id}.":private_taxonomy";
    if (exists $ws_hash->{$new_ws}){

    	print "\n\nFound an existing workspace $new_ws that is assigned for storing private taxa, using $new_ws...  \n";
    	$private_tax_ws_ref = $ws_hash->{"private_taxonomy"}->[6];

    }
    else{

    	print "\n\nCreating a new workspace $new_ws for storing private taxa\n";
    	my $create_ws_params = {
    		workspace => $new_ws,
    		globalread => "n",
    		description => "store private taxonomy objects"
    	};

    	my $info = $wsClient->create_workspace($create_ws_params);
    	$private_tax_ws_ref = $info->[0];
    	#print &Dumper ($info);
    }


    #Fetching parent taxonomy
    my $parent_taxon=$wsClient->get_objects([{ref=>$params->{parent}}])->[0]{data};
    my $tempL =~ s/\"//, $parent_taxon->{scientific_lineage};

    my $tax_data = {

    	scientific_name => $params->{scientific_name},
    	domain => $params->{domain},
    	taxonomy_id => 100,
    	GenBank_hidden_flag => 0,
    	inherited_GC_flag => 0,
    	aliases => $params->{aliases},
    	parent_taxon_ref => $params->{parent},
    	genetic_code => $params->{genetic_code},
    	rank => "no rank",
    	scientific_lineage => $parent_taxon->{scientific_lineage}.";".$parent_taxon->{scientific_name}


    };

    my $obj_info_list = undef;
    eval {
        $obj_info_list = $wsClient->save_objects({
            'id'=>$private_tax_ws_ref,
            'objects'=>[{
                'type'=>'KBaseGenomeAnnotations.Taxon',
                'data'=>$tax_data,
                'name'=>$tax_data->{taxonomic_id}."_taxon",
                'hidden' => 0,
                'provenance'=>$provenance
            }]
        });
    };
    if ($@) {
        die "Error saving modified genome object to workspace:\n".$@;
    }
    my $info_ref = $obj_info_list->[0];
    my $ob_ref =  $info_ref->[6]."/".$info_ref->[0]."/".$info_ref->[4];
    #print &Dumper ($info_ref);


    $output = {
        scientific_name => $params->{scientific_name},
     	ref => $ob_ref

    };

    print "\n\nSucessfully created new taxon for $params->{scientific_name}\n\n";
    #print &Dumper ($output);

    return $output;
    #END create_taxonomy
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to create_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'create_taxonomy');
    }
    return($output);
}




=head2 change_taxa

  $output = $obj->change_taxa($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.ChangeTaxaInputParams
$output is a taxonomy_service.ChangeTaxaOut
ChangeTaxaInputParams is a reference to a hash where the following keys are defined:
	input_genome has a value which is a string
	scientific_name has a value which is a string
	workspace has a value which is a string
	output_genome has a value which is a string
ChangeTaxaOut is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
	taxa_ref has a value which is a string
	genome_name has a value which is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.ChangeTaxaInputParams
$output is a taxonomy_service.ChangeTaxaOut
ChangeTaxaInputParams is a reference to a hash where the following keys are defined:
	input_genome has a value which is a string
	scientific_name has a value which is a string
	workspace has a value which is a string
	output_genome has a value which is a string
ChangeTaxaOut is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
	taxa_ref has a value which is a string
	genome_name has a value which is a string


=end text



=item Description



=back

=cut

sub change_taxa
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to change_taxa:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'change_taxa');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN change_taxa
    print &Dumper ($params);
    my $token=$ctx->token;
    my $provenance=$ctx->provenance;
    my $wsClient=Bio::KBase::workspace::Client->new($self->{'workspace-url'},token=>$token);
    my $genome_taxon=$wsClient->get_objects([{name =>$params->{input_genome}, workspace=>$params->{workspace}}])->[0]{data};
    if (defined $genome_taxon->{taxon_ref}){
        print "Currently your genome is assigned to the taxa $genome_taxon->{taxon_ref}\n";
    }

    $params->{taxa_ref} = "1779/87821/1"; # This param has a hard coded value until the method is fully working and return the actual value
    $genome_taxon->{taxon_ref} = $params->{taxa_ref};

    print "You have assigned or modifed the taxa to $params->{scientific_name} for the genome $genome_taxon->{scientific_name}\n";

    my $obj_info_list = undef;
    eval {
        $obj_info_list = $wsClient->save_objects({
            'workspace'=> $params->{workspace},
            'objects'=>[{
                'type'=>'KBaseGenomes.Genome',
                'data'=>$genome_taxon,
                'name'=>$params->{output_genome},
                'provenance'=>$provenance
            }]
        });
    };
    if ($@) {
        die "Error saving modified genome object to workspace:\n".$@;
    }
    my $info_ref = $obj_info_list->[0];
    my $ob_ref =  $info_ref->[6]."/".$info_ref->[0]."/".$info_ref->[4];
    print &Dumper ($info_ref);


    $output = {
        genome_ref => $ob_ref,
        taxa_ref => $params->{taxa_ref},
        genome_name => $genome_taxon->{scientific_name}

    };

    return $output;
    #END change_taxa
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to change_taxa:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'change_taxa');
    }
    return($output);
}




=head2 get_taxonomies_by_id

  $output = $obj->get_taxonomies_by_id($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.GetTaxonomiesIdInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetTaxonomiesIdInputParams is a reference to a hash where the following keys are defined:
	taxonomy_object_refs has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
ObjectReference is a string
GetTaxonomiesOut is a reference to a hash where the following keys are defined:
	taxa_ref has a value which is a string
	lineage_genomes has a value which is a reference to a list where each element is a taxonomy_service.lineage_steps
lineage_steps is a reference to a hash where the following keys are defined:
	lineage_step has a value which is a string
	lineage_count has a value which is an int

</pre>

=end html

=begin text

$params is a taxonomy_service.GetTaxonomiesIdInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetTaxonomiesIdInputParams is a reference to a hash where the following keys are defined:
	taxonomy_object_refs has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
ObjectReference is a string
GetTaxonomiesOut is a reference to a hash where the following keys are defined:
	taxa_ref has a value which is a string
	lineage_genomes has a value which is a reference to a list where each element is a taxonomy_service.lineage_steps
lineage_steps is a reference to a hash where the following keys are defined:
	lineage_step has a value which is a string
	lineage_count has a value which is an int


=end text



=item Description



=back

=cut

sub get_taxonomies_by_id
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_taxonomies_by_id:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_taxonomies_by_id');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN get_taxonomies_by_id


    #END get_taxonomies_by_id
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_taxonomies_by_id:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_taxonomies_by_id');
    }
    return($output);
}




=head2 get_genomes_for_taxonomy

  $output = $obj->get_genomes_for_taxonomy($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.GetGenomesTaxonomyInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetGenomesTaxonomyInputParams is a reference to a hash where the following keys are defined:
	taxa_ref has a value which is a string
GetTaxonomiesOut is a reference to a hash where the following keys are defined:
	taxa_ref has a value which is a string
	lineage_genomes has a value which is a reference to a list where each element is a taxonomy_service.lineage_steps
lineage_steps is a reference to a hash where the following keys are defined:
	lineage_step has a value which is a string
	lineage_count has a value which is an int

</pre>

=end html

=begin text

$params is a taxonomy_service.GetGenomesTaxonomyInputParams
$output is a taxonomy_service.GetTaxonomiesOut
GetGenomesTaxonomyInputParams is a reference to a hash where the following keys are defined:
	taxa_ref has a value which is a string
GetTaxonomiesOut is a reference to a hash where the following keys are defined:
	taxa_ref has a value which is a string
	lineage_genomes has a value which is a reference to a list where each element is a taxonomy_service.lineage_steps
lineage_steps is a reference to a hash where the following keys are defined:
	lineage_step has a value which is a string
	lineage_count has a value which is an int


=end text



=item Description



=back

=cut

sub get_genomes_for_taxonomy
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_genomes_for_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_genomes_for_taxonomy');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN get_genomes_for_taxonomy

    my $taxonomy_core = "taxonomy_ci";
    my $solrurl = $self->{_SOLR_URL};
    my $method = 'GET';
    $params->{start} = 0;
    $params->{limit} = 5;
    print &Dumper ($params);
    if (!defined $params->{taxa_ref}){
        die "Define taxa ref\n";
    }
    my $df = "ws_ref";
    my $genome_taxon = get_taxa_by_ref($taxonomy_core, $self->{_SOLR_URL}, $params->{taxa_ref}, $params->{start}, $params->{limit}, $df, $method);
    #print &Dumper ($genome_taxon);
    my @each_lineage = split /;/, $genome_taxon->{response}->{docs}->[0]->{scientific_lineage};
    my $get_genomes_out = {
        taxa_ref => $params->{taxa_ref},
        lineage_genomes => []
    };
    foreach my $el (reverse @each_lineage){
        my $each_node = $el;
        my $each_taxa = format_taxa_name($el);
        my $genome_response = get_genomes ($taxonomy_core, $self->{_SOLR_URL}, $each_taxa, $params->{start}, $params->{limit}, $method);
        #print "$el \t$genome_response->{response}->{numFound}\n";
        #Packaging each node in the lineage
        my $each_step = {
            lineage_step => $each_node,
            lineage_count => $genome_response->{response}->{numFound},
            #search_word => $el
        };
        push (@{$get_genomes_out->{lineage_genomes}}, $each_step);
    }

    $output = $get_genomes_out;
    #print &Dumper ($output);
    #END get_genomes_for_taxonomy
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_genomes_for_taxonomy:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_genomes_for_taxonomy');
    }
    return($output);
}




=head2 get_genomes_for_taxa_group

  $output = $obj->get_genomes_for_taxa_group($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a taxonomy_service.GetGenomesTaxaGroupInputParams
$output is a taxonomy_service.GetGenomesOut
GetGenomesTaxaGroupInputParams is a reference to a hash where the following keys are defined:
	start has a value which is an int
	limit has a value which is an int
	lineage_step has a value which is a string
GetGenomesOut is a reference to a hash where the following keys are defined:
	lineage_step has a value which is a string
	lineage_count has a value which is an int
	view_info has a value which is a reference to a hash where the key is a string and the value is a taxonomy_service.view_each_lineage_info
	TaxaInfo has a value which is a reference to a list where each element is a taxonomy_service.TaxaViewerOutput
view_each_lineage_info is a reference to a hash where the following keys are defined:
	parent_name has a value which is a string
	aliases has a value which is a string
	scientific_lineage has a value which is a string
	domain has a value which is a string
	ws_ref has a value which is a string
	scientific_name has a value which is a string
	parent_ref has a value which is a string
TaxaViewerOutput is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	kingdom has a value which is a string
	ws_ref has a value which is a string
	parent_taxon_ref has a value which is a string
	deleted has a value which is an int
	domain has a value which is a string
	category has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	scientific_lineage has a value which is a string

</pre>

=end html

=begin text

$params is a taxonomy_service.GetGenomesTaxaGroupInputParams
$output is a taxonomy_service.GetGenomesOut
GetGenomesTaxaGroupInputParams is a reference to a hash where the following keys are defined:
	start has a value which is an int
	limit has a value which is an int
	lineage_step has a value which is a string
GetGenomesOut is a reference to a hash where the following keys are defined:
	lineage_step has a value which is a string
	lineage_count has a value which is an int
	view_info has a value which is a reference to a hash where the key is a string and the value is a taxonomy_service.view_each_lineage_info
	TaxaInfo has a value which is a reference to a list where each element is a taxonomy_service.TaxaViewerOutput
view_each_lineage_info is a reference to a hash where the following keys are defined:
	parent_name has a value which is a string
	aliases has a value which is a string
	scientific_lineage has a value which is a string
	domain has a value which is a string
	ws_ref has a value which is a string
	scientific_name has a value which is a string
	parent_ref has a value which is a string
TaxaViewerOutput is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	kingdom has a value which is a string
	ws_ref has a value which is a string
	parent_taxon_ref has a value which is a string
	deleted has a value which is an int
	domain has a value which is a string
	category has a value which is a string
	aliases has a value which is a reference to a list where each element is a string
	scientific_lineage has a value which is a string


=end text



=item Description



=back

=cut

sub get_genomes_for_taxa_group
{
    my $self = shift;
    my($params) = @_;

    my @_bad_arguments;
    (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument \"params\" (value was \"$params\")");
    if (@_bad_arguments) {
	my $msg = "Invalid arguments passed to get_genomes_for_taxa_group:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_genomes_for_taxa_group');
    }

    my $ctx = $taxonomy_service::taxonomy_serviceServer::CallContext;
    my($output);
    #BEGIN get_genomes_for_taxa_group
    my $taxonomy_core = "taxonomy_ci";
    my $solrurl = $self->{_SOLR_URL};
    my $method = 'GET';

    print &Dumper ($params);
    if (!defined $params->{lineage_step}){

        die "Define lineage node\n";
    }
    if (!defined $params->{start} || !defined $params->{limit}){

        die "Define start param and number of rows for solr query\n";
    }
    my $each_taxa = format_taxa_name($params->{lineage_step});

    my $genome_response = get_genomes ($taxonomy_core, $self->{_SOLR_URL}, $each_taxa, $params->{start}, $params->{limit}, $method);

    my $df = "scientific_name";
    my $view_info_for_each_node = get_node_info ($taxonomy_core, $self->{_SOLR_URL}, $each_taxa, $params->{start}, $params->{limit}, $df, $method);

    my $def = "ws_ref";
    my $parent_info = get_parent ($solrurl, $taxonomy_core, $view_info_for_each_node->{response}->{docs}->[0]->{parent_taxon_ref}, $method, $def);

    my $view_info = {
        scientific_name => $view_info_for_each_node->{response}->{docs}->[0]->{scientific_name},
        aliases => $view_info_for_each_node->{response}->{docs}->[0]->{aliases},
        scientific_lineage => $view_info_for_each_node->{response}->{docs}->[0]->{scientific_lineage},
        domain => $view_info_for_each_node->{response}->{docs}->[0]->{domain},
        ws_ref => $view_info_for_each_node->{response}->{docs}->[0]->{ws_ref},
        parent_name => $parent_info->{response}->{docs}->[0]->{scientific_name},
        parent_ref => $parent_info->{response}->{docs}->[0]->{ws_ref},
    };


    my $get_genomes_out = {
        lineage_step => $each_taxa,
        lineage_count => $genome_response->{response}->{numFound},
        view_info => $view_info,
        TaxaInfo => []
    };

    for (my $i=0; $i< @{$genome_response->{response}->{docs}}; $i++){
        my $eg = $genome_response->{response}->{docs}->[$i];
        my $each_genome = {
            scientific_name => $eg->{scientific_name},
            kingdom => $eg->{kingdom},
            ws_ref => $eg->{ws_ref},
            parent_taxon_ref => $eg->{parent_taxon_ref},
            deleted => $eg->{deleted},
            scientific_lineage => $eg->{scientific_lineage},
            aliases => $eg->{aliases},
            domain => $eg->{domain},
            category => "public"
        };
        push (@{$get_genomes_out->{TaxaInfo}} ,$each_genome);
    }

    $output = $get_genomes_out;
    #print &Dumper ($output);
    #END get_genomes_for_taxa_group
    my @_bad_returns;
    (ref($output) eq 'HASH') or push(@_bad_returns, "Invalid type for return variable \"output\" (value was \"$output\")");
    if (@_bad_returns) {
	my $msg = "Invalid returns passed to get_genomes_for_taxa_group:\n" . join("", map { "\t$_\n" } @_bad_returns);
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
							       method_name => 'get_genomes_for_taxa_group');
    }
    return($output);
}




=head2 status

  $return = $obj->status()

=over 4

=item Parameter and return types

=begin html

<pre>
$return is a string
</pre>

=end html

=begin text

$return is a string

=end text

=item Description

Return the module status. This is a structure including Semantic Versioning number, state and git info.

=back

=cut

sub status {
    my($return);
    #BEGIN_STATUS
    $return = {"state" => "OK", "message" => "", "version" => $VERSION,
               "git_url" => $GIT_URL, "git_commit_hash" => $GIT_COMMIT_HASH};
    #END_STATUS
    return($return);
}

=head1 TYPES



=head2 bool

=over 4



=item Description

A binary boolean


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ObjectReference

=over 4



=item Description

workspace ref to an object


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 DropDownItemInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
private has a value which is an int
public has a value which is an int
local has a value which is an int
search has a value which is a string
limit has a value which is an int
start has a value which is an int
workspace has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
private has a value which is an int
public has a value which is an int
local has a value which is an int
search has a value which is a string
limit has a value which is an int
start has a value which is an int
workspace has a value which is a string


=end text

=back



=head2 DropDownItem

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
label has a value which is a string
id has a value which is a string
category has a value which is a string
parent has a value which is a string
parent_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
label has a value which is a string
id has a value which is a string
category has a value which is a string
parent has a value which is a string
parent_ref has a value which is a string


=end text

=back



=head2 DropDownData

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
num_of_hits has a value which is an int
hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
num_of_hits has a value which is an int
hits has a value which is a reference to a list where each element is a taxonomy_service.DropDownItem


=end text

=back



=head2 CreateTaxonomyInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
rank has a value which is a string
comments has a value which is a string
genetic_code has a value which is a string
aliases has a value which is a reference to a list where each element is a string
workspace has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
rank has a value which is a string
comments has a value which is a string
genetic_code has a value which is a string
aliases has a value which is a reference to a list where each element is a string
workspace has a value which is a string


=end text

=back



=head2 CreateTaxonomyOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ref has a value which is a taxonomy_service.ObjectReference
scientific_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ref has a value which is a taxonomy_service.ObjectReference
scientific_name has a value which is a string


=end text

=back



=head2 GetTaxonomiesIdInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxonomy_object_refs has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxonomy_object_refs has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference


=end text

=back



=head2 TaxonInfo

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
ref has a value which is a taxonomy_service.ObjectReference
scientific_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
ref has a value which is a taxonomy_service.ObjectReference
scientific_name has a value which is a string


=end text

=back



=head2 Taxon

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
children has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
decorated_children has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
scientific_lineage has a value which is a reference to a list where each element is a string
decorated_scientific_lineage has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
scientific_name has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
aliases has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
children has a value which is a reference to a list where each element is a taxonomy_service.ObjectReference
decorated_children has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
scientific_lineage has a value which is a reference to a list where each element is a string
decorated_scientific_lineage has a value which is a reference to a list where each element is a taxonomy_service.TaxonInfo
scientific_name has a value which is a string
taxonomic_id has a value which is an int
kingdom has a value which is a string
domain has a value which is a string
genetic_code has a value which is an int
aliases has a value which is a reference to a list where each element is a string


=end text

=back



=head2 ChangeTaxaInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
input_genome has a value which is a string
scientific_name has a value which is a string
workspace has a value which is a string
output_genome has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
input_genome has a value which is a string
scientific_name has a value which is a string
workspace has a value which is a string
output_genome has a value which is a string


=end text

=back



=head2 ChangeTaxaOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_ref has a value which is a string
taxa_ref has a value which is a string
genome_name has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_ref has a value which is a string
taxa_ref has a value which is a string
genome_name has a value which is a string


=end text

=back



=head2 TaxaViewerInput

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxa_ref has a value which is a string
parent_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxa_ref has a value which is a string
parent_ref has a value which is a string


=end text

=back



=head2 GenomeTaxaCount

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
num_genomes has a value which is an int
lineage has a value which is a string
lineage_ref has a value which is a string
lineage_pos has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
num_genomes has a value which is an int
lineage has a value which is a string
lineage_ref has a value which is a string
lineage_pos has a value which is an int


=end text

=back



=head2 TaxaViewerOutput

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
kingdom has a value which is a string
ws_ref has a value which is a string
parent_taxon_ref has a value which is a string
deleted has a value which is an int
domain has a value which is a string
category has a value which is a string
aliases has a value which is a reference to a list where each element is a string
scientific_lineage has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
kingdom has a value which is a string
ws_ref has a value which is a string
parent_taxon_ref has a value which is a string
deleted has a value which is an int
domain has a value which is a string
category has a value which is a string
aliases has a value which is a reference to a list where each element is a string
scientific_lineage has a value which is a string


=end text

=back



=head2 lineage_steps

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
lineage_step has a value which is a string
lineage_count has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
lineage_step has a value which is a string
lineage_count has a value which is an int


=end text

=back



=head2 GetTaxonomiesOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxa_ref has a value which is a string
lineage_genomes has a value which is a reference to a list where each element is a taxonomy_service.lineage_steps

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxa_ref has a value which is a string
lineage_genomes has a value which is a reference to a list where each element is a taxonomy_service.lineage_steps


=end text

=back



=head2 GetGenomesTaxonomyInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
taxa_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
taxa_ref has a value which is a string


=end text

=back



=head2 view_each_lineage_info

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
parent_name has a value which is a string
aliases has a value which is a string
scientific_lineage has a value which is a string
domain has a value which is a string
ws_ref has a value which is a string
scientific_name has a value which is a string
parent_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
parent_name has a value which is a string
aliases has a value which is a string
scientific_lineage has a value which is a string
domain has a value which is a string
ws_ref has a value which is a string
scientific_name has a value which is a string
parent_ref has a value which is a string


=end text

=back



=head2 GetGenomesOut

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
lineage_step has a value which is a string
lineage_count has a value which is an int
view_info has a value which is a reference to a hash where the key is a string and the value is a taxonomy_service.view_each_lineage_info
TaxaInfo has a value which is a reference to a list where each element is a taxonomy_service.TaxaViewerOutput

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
lineage_step has a value which is a string
lineage_count has a value which is an int
view_info has a value which is a reference to a hash where the key is a string and the value is a taxonomy_service.view_each_lineage_info
TaxaInfo has a value which is a reference to a list where each element is a taxonomy_service.TaxaViewerOutput


=end text

=back



=head2 GetGenomesTaxaGroupInputParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
start has a value which is an int
limit has a value which is an int
lineage_step has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
start has a value which is an int
limit has a value which is an int
lineage_step has a value which is a string


=end text

=back



=cut

1;
