import { FC } from "react";
import {Layout, Typography} from "antd";


export const PreHeader: FC = () => {
    return (
        <Layout.Header style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '10px  24px',height: "auto", backgroundColor: '#3D5A80' }}>
            <Typography style={{color: 'white'}}>Ab sofort auch Skirennen verfügbar!  - Jetzt abbonieren</Typography>
            <Typography style={{color: 'white'}}>Projekt unterstützen? - buy us a Coffee</Typography>
        </Layout.Header>
    );
};
