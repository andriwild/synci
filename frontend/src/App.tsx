
import './App.css'
import { GoogleOAuthProvider, GoogleLogin } from '@react-oauth/google';

function App() {

    const handleLoginSuccess = (response: any) => {
        console.log("Loginsucess",response);
        // save the token to local storage


        fetch('http://localhost:8080/api/auth/google', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${response.credential}`
            }
        }).then(res => res.json())
            .then(data => {
                console.log(data);
            });
    };

    const handleLoginFailure = (error: any) => {
        console.error('Login failed', error);
    };
  return (
    <>
        <GoogleOAuthProvider clientId="5100823542-pasq5mdgfm0uqu5q4n8rbss8r9k7pa12.apps.googleusercontent.com">
            <div>
                <h1>Login with Google</h1>
                <GoogleLogin
                    onSuccess={handleLoginSuccess}
                    onError={() => handleLoginFailure('error')}
                />
            </div>
        </GoogleOAuthProvider>
    </>
  )
}

export default App
