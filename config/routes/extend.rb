scope '/' do
    root 'static_pages#home'
    match 'home',       to: 'static_pages#home',     via: 'get'
    match '/example',   to: 'static_pages#example',  via: 'get'

    match 'submit', to: 'static_pages#submit', via: 'post'
end