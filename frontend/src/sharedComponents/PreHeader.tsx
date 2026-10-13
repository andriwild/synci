import {FC} from "react";
import {Layout} from "antd";
import {Link} from "react-router-dom";
import {DonationModal} from "./DonationModal.tsx";
import {useResponsive} from "../utils/useResponsive.ts";
import "./AppShell.css";

export const PreHeader: FC = () => {
    const {isMobile} = useResponsive();
    return (
        <Layout.Header className="pre-header">
            <Link to="/organisationen" style={{color: "white"}}>
                Jetzt eigene Organisationen erfassen
            </Link>
            {!isMobile && <DonationModal buttonStyle={"text"} buttonText={"Projekt unterstützen - hier twinten"} textColor={"white"}/>}
        </Layout.Header>
    );
};
