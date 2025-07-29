import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import {Provider} from 'react-redux';
import {store} from "./app/store.ts";
import {Auth0Provider} from "@auth0/auth0-react";

createRoot(document.getElementById('root')!).render(
  <StrictMode>
      <Auth0Provider
          domain={import.meta.env.VITE_AUTH0_DOMAIN}
          clientId={import.meta.env.VITE_AUTH0_CLIENT_ID}
          authorizationParams={{
              redirect_uri: window.location.origin,
              audience: 'https://synci.awild.ch',
      }}
      >
    <Provider store={store}>
        <App />
    </Provider>
        </Auth0Provider>
  </StrictMode>,
)
