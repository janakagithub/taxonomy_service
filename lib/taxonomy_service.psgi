use taxonomy_service::taxonomy_serviceImpl;

use taxonomy_service::taxonomy_serviceServer;
use Plack::Middleware::CrossOrigin;



my @dispatch;

{
    my $obj = taxonomy_service::taxonomy_serviceImpl->new;
    push(@dispatch, 'taxonomy_service' => $obj);
}


my $server = taxonomy_service::taxonomy_serviceServer->new(instance_dispatch => { @dispatch },
				allow_get => 0,
			       );

my $handler = sub { $server->handle_input(@_) };

$handler = Plack::Middleware::CrossOrigin->wrap( $handler, origins => "*", headers => "*");
