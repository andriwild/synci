import {BrowserRouter as Router, Route, Routes} from 'react-router-dom';
import {UserConfigForm} from './pages/UserConfigForm.tsx';
import './App.css';
import {Home} from "./pages/Home.tsx";
import {Header} from "./components/Header.tsx";
import {ConfigProvider, Layout, theme} from "antd";
import {Footer} from "./components/Footer.tsx";
import {Content} from "antd/es/layout/layout";
import {UserConfig} from "./pages/UserConfigs.tsx";

function App() {

    const handleLoginSuccess = (response) => {
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

    const handleLoginFailure = (error) => {
        console.error('Login failed', error);
    };

    return (
        <Router>
            <ConfigProvider
                theme={{
                    algorithm: theme.defaultAlgorithm,
                    token: {
                        // Seed Token
                        colorPrimary: '#545454',
                        borderRadius: 20,
                        // Alias Token
                        colorBgContainer: '#eaeaea',
                    },
                }}
            >
            <Layout style={{ minHeight: '100vh', minWidth: '100vw' }}>
                <Header />
                <Content>
                    <Routes>
                        <Route path="/" element={<Home />} />
                        <Route path="/config/" element={<UserConfig />} />
                        <Route path="/config/:id" element={<UserConfigForm />} />
                    </Routes>
                </Content>
                <Footer />
            </Layout>
            </ConfigProvider>
        </Router>
    );
}

export default App;
