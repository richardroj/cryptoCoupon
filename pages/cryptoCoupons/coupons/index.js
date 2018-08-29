import React, { Component } from 'react';
import { Button, Table } from 'semantic-ui-react';
import { Link } from '../../../routes';
import Layout from '../../../components/Layout';
import CryptoCoupon from '../../../ethereum/cryptoCoupon';
import CouponRow from '../../../components/CouponRow';

class CouponIndex extends Component {
  static async getInitialProps(props) {
    const { address } = props.query;
    const cryptoCoupon = CryptoCoupon(address);
    const couponCount = await cryptoCoupon.methods.getCouponsCount().call();
    //const approversCount = await campaign.methods.approversCount().call();

    const coupons = await Promise.all(
      Array(parseInt(couponCount))
        .fill()
        .map((element, index) => {
          return cryptoCoupon.methods.coupons(index).call();
        })
    );

    return { address, coupons, couponCount };
  }

  renderRows() {
    return this.props.coupons.map((coupon, index) => {
      return (
        <CouponRow
          key={index}
          id={index}
          coupon={coupon}
          address={this.props.address}
          
        />
      );
    });
  }

  render() {
    const { Header, Row, HeaderCell, Body } = Table;

    return (
      <Layout>
        <h3>Coupons</h3>
        <Link route={`/cryptoCoupons/${this.props.address}/coupons/new`}>
          <a>
            <Button primary floated="right" style={{ marginBottom: 10 }}>
              Add Coupon
            </Button>
          </a>
        </Link>
        <Table>
          <Header>
            <Row>
              <HeaderCell>ID</HeaderCell>
              <HeaderCell>Name</HeaderCell>
              <HeaderCell>Description</HeaderCell>
              <HeaderCell>Serial Number</HeaderCell>
              <HeaderCell>Value</HeaderCell>
              <HeaderCell>Approve</HeaderCell>
              <HeaderCell>Finalize</HeaderCell>
            </Row>
          </Header>
          <Body>{this.renderRows()}</Body>
        </Table>
        <div>Found {this.props.couponCount} coupons.</div>
      </Layout>
    );
  }
}

export default CouponIndex;
