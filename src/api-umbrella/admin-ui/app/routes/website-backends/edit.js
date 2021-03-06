import Form from './form';

export default Form.extend({
  model(params) {
    this.clearStoreCache();
    return this.store.findRecord('website-backend', params.website_backend_id, { reload: true });
  },
});
