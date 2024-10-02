import './App.css'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import {ConfigProvider, Layout, theme} from "antd";
import {Content} from "antd/es/layout/layout";
import {UserConfigForm} from "./pages/UserConfigForm.tsx";
import {Header} from "./components/Header.tsx";
import {Footer} from "./components/Footer.tsx";
import {UserConfigsPage} from "./pages/UserConfigsPage.tsx";
import {Home} from "./pages/Home.tsx";


function App() {
    return (
        <Router>
            <ConfigProvider
                theme={{
                    algorithm: theme.defaultAlgorithm,
                    token: {
                        colorPrimary: '#545454',
                        borderRadius: 20,
                        colorBgContainer: '#eaeaea',
                    },
                }}
            >
            <Layout style={{ minHeight: '100vh', minWidth: '100vw' }}>
                <Header />
                <Content>
                    <Routes>
                        <Route path="/" element={<Home />} />
                        <Route path="/config/" element={<UserConfigsPage />} />
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
