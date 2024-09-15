import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { UserConfigForm } from './components/UserConfigForm.tsx';
import './App.css';
import { Home } from "./pages/Home.tsx";
import { Header } from "./components/Header.tsx";
import { Layout } from "antd";
import { Footer } from "./components/Footer.tsx";
import {Content} from "antd/es/layout/layout";
import {UserConfig} from "./pages/UserConfigs.tsx";

function App() {
    return (
        <Router>
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
        </Router>
    );
}

export default App;
