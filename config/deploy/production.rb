set :stage, :production

server '162.243.232.199', user: 'deploy', roles: %w{web app db}