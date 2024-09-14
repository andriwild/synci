import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { UserConfigForm } from './pages/UserConfigForm.tsx';
import './App.css';
import {Home} from "./pages/Home.tsx";

function App() {
    return (
        <Router>
            <Routes>
                    <Route path="/" element={<Home />} />
                    <Route path="/config" element={<UserConfigForm />} />
            </Routes>
        </Router>
    );
}

export default App;
