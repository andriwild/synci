import {Menu, Layout} from "antd";

export const Header = () => {

    const items = [
        {
            key: '1',
            label: 'Home'
        },
        {
            key: '2',
            label: 'Konfigurationen'
        }
    ]

    return (
        <Layout.Header>
            <div className="demo-logo" />
            <Menu
                theme="dark"
                mode="horizontal"
                defaultSelectedKeys={['2']}
                items={items}
                style={{ flex: 1, minWidth: 0 }}
            />
        </Layout.Header>
    )
}