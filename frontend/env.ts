interface RuntimeConfig {
  BACKEND_URL: string;
  BACKEND_HOST: string;
  AUTH0_DOMAIN: string;
  AUTH0_CLIENT_ID: string;
  AUTH0_AUDIENCE: string;
}

declare global {
  interface Window {
    ENV?: RuntimeConfig;
  }
}

const getConfigValue = (key: keyof RuntimeConfig): string => {
  if (window.ENV && window.ENV[key] && !window.ENV[key].includes('PLACEHOLDER')) {
    return window.ENV[key];
  }
  
  const viteKey = `VITE_${key}` as keyof ImportMetaEnv;
  return import.meta.env[viteKey] || '';
};

export const VITE_BACKEND_URL = getConfigValue('BACKEND_URL');
export const VITE_BACKEND_HOST = getConfigValue('BACKEND_HOST');
export const VITE_AUTH0_DOMAIN = getConfigValue('AUTH0_DOMAIN');
export const VITE_AUTH0_CLIENT_ID = getConfigValue('AUTH0_CLIENT_ID');
// Without an audience Auth0 issues an encrypted token the backend rejects, e.g. with a stale config.js
export const VITE_AUTH0_AUDIENCE = getConfigValue('AUTH0_AUDIENCE') || 'https://synci.ch/api';

// for debugging
if (import.meta.env.DEV) {
  console.log('Runtime Config loaded:', {
    BACKEND_URL: VITE_BACKEND_URL,
    BACKEND_HOST: VITE_BACKEND_HOST,
    AUTH0_DOMAIN: VITE_AUTH0_DOMAIN,
    AUTH0_CLIENT_ID: VITE_AUTH0_CLIENT_ID,
    AUTH0_AUDIENCE: VITE_AUTH0_AUDIENCE,
  });
}
