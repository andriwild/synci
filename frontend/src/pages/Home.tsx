import {useNavigate} from "react-router-dom";

export const Home = () => {
    const navigate = useNavigate();

    return (
        <div>
            <div>Hello Home</div>
            <button onClick={() => navigate('/config')}>Config erstellen</button>
        </div>
    )
}