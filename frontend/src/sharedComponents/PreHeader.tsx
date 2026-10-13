import {FC} from "react";
import {Layout, Typography} from "antd";
import {useNavigate} from "react-router-dom";
import {DonationModal} from "./DonationModal.tsx";
import {useResponsive} from "../utils/useResponsive.ts";
import "./AppShell.css";

export const PreHeader: FC = () => {
    const {isMobile} = useResponsive();
    const navigate = useNavigate();
    return (
        <Layout.Header className="pre-header">
            <Typography.Link style={{color: "white"}} onClick={() => navigate("/organisationen")}>
                Jetzt eigene Organisationen erfassen
            </Typography.Link>
            {!isMobile && <DonationModal buttonStyle={"text"} buttonText={"Projekt unterstützen - hier twinten"} textColor={"white"}/>}
        </Layout.Header>
    );
};
