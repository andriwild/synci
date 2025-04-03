import {FC} from "react";
import {Layout, Typography} from "antd";
import useBreakpoint from "antd/es/grid/hooks/useBreakpoint";
import {DonationModal} from "./DonationModal.tsx";


export const PreHeader: FC = () => {
   const screens = useBreakpoint();
    return (
        <Layout.Header style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '5px  24px',height: "auto", backgroundColor: '#3D5A80' }}>
            <Typography style={{color: 'white'}}>Ab sofort auch Skirennen verfügbar!  - Jetzt abbonieren</Typography>
            { screens.md && <DonationModal buttonStyle={"text"} buttonText={"Projekt unterstützen - hier twinten"} textColor={"white"}/>}
        </Layout.Header>

    );
};
