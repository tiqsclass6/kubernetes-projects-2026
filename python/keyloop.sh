for i in {1..100}; do
  curl -i http://34.30.43.65/hello -H "apikey: super-secret-key"
  echo ""
done